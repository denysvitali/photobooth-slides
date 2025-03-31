<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'

// Configurable parameters (fixed values since controls are hidden)
const dutyCycle = ref(50) // 0-100%
const frequency = ref(1) // Hz for visualization purposes
const animationId = ref(0)
const time = ref(0)
const autoChangeTimer = ref<ReturnType<typeof setInterval> | null>(null)
const autoChangeDirection = ref(1) // 1 = increasing, -1 = decreasing

// Derived values
const period = computed(() => 1000 / frequency.value) // in ms
const onTime = computed(() => (dutyCycle.value / 100) * period.value)

// LED brightness is proportional to duty cycle
const brightness = computed(() => Math.round(dutyCycle.value))

// Average voltage (proportional to duty cycle)
const avgVoltage = computed(() => (dutyCycle.value / 100 * 5).toFixed(1)) // Assuming 5V max

// Current signal state
const isHigh = computed(() => time.value % period.value < onTime.value)

// Animation function for the waveform
function animate() {
  time.value = (time.value + 10) % (period.value * 2)
  animationId.value = requestAnimationFrame(animate)
}

// Auto-change mode for demonstration
function startAutoChange() {
  if (autoChangeTimer.value) clearInterval(autoChangeTimer.value)
  
  autoChangeTimer.value = setInterval(() => {
    // Change duty cycle automatically
    dutyCycle.value += autoChangeDirection.value
    
    // Reverse direction at limits
    if (dutyCycle.value >= 100 || dutyCycle.value <= 5) {
      autoChangeDirection.value *= -1
    }
  }, 100)
}

onMounted(() => {
  animationId.value = requestAnimationFrame(animate)
  startAutoChange()
})

onUnmounted(() => {
  cancelAnimationFrame(animationId.value)
  if (autoChangeTimer.value) clearInterval(autoChangeTimer.value)
})

type Point = {
  x: number
  y: number
}

// Generate points for the PWM waveform
const wavePoints = computed(() => {
  const points: Array<Point> = []
  const width = 400 // SVG width
  const height = 80 // SVG height
  const cycles = 2 // How many full cycles to show
  const pointsPerCycle = 100
  
  for (let i = 0; i <= cycles * pointsPerCycle; i++) {
    const x = (i / (cycles * pointsPerCycle)) * width
    const cyclePosition = (i % pointsPerCycle) / pointsPerCycle
    
    // High during onTime, low during offTime
    const y = cyclePosition < (dutyCycle.value / 100) ? 20 : 60
    
    points.push({ x, y })
  }
  
  return points
})

// Generate the SVG path for the waveform
const wavePath = computed(() => {
  if (wavePoints.value.length === 0) return ''
  
  return wavePoints.value.map((p, idx) => 
    (idx === 0 ? 'M' : 'L') + `${p.x},${p.y}`
  ).join(' ')
})

// Format period to avoid NaN - updates in real-time with frequency changes
const periodMs = computed(() => {
  if (frequency.value <= 0) return "1000";
  const ms = Math.round(1000/frequency.value);
  return isNaN(ms) ? "1000" : ms.toString();
})

// Format on-time to avoid NaN - updates in real-time
const onTimeMs = computed(() => {
  if (frequency.value <= 0 || dutyCycle.value <= 0) return "0";
  const ms = Math.round(dutyCycle.value/100 * period.value);
  return isNaN(ms) ? "0" : ms.toString();
})

// Force update when frequency changes to ensure period markers update
watch(frequency, () => {
  // This watch forces Vue to recognize the change and update the display
}, { immediate: true })
</script>

<template>
  <div class="pwm-demo">
    <div class="demo-header">
      <h2>Pulse Width Modulation (PWM) Demo</h2>
      <div class="parameters">
        <span>Duty Cycle: {{ dutyCycle }}%</span>
        <span>Frequency: {{ frequency.toFixed(1) }} Hz</span>
      </div>
    </div>

    <div class="visualization-container">
      <div class="waveform-container">
        <svg width="400" height="100" class="waveform">
          <!-- Waveform background grid -->
          <g class="grid">
            <line x1="0" y1="40" x2="400" y2="40" class="center-line" />
            <line v-for="i in 10" :key="`v-${i}`" 
                  :x1="i * 40" :y1="0" :x2="i * 40" :y2="80" class="grid-line" />
          </g>
          
          <!-- PWM signal path -->
          <path :d="wavePath" class="wave-path" />
          
          <!-- Average value line -->
          <line x1="0" :y1="60 - (dutyCycle/100) * 40" 
                x2="400" :y2="60 - (dutyCycle/100) * 40"
                class="avg-line" />
          
          <!-- Period markers - using :key to force update -->
          <g class="markers" :key="`markers-${periodMs}-${onTimeMs}`">
            <!-- Period annotation -->
            <line x1="0" y1="70" x2="200" y2="70" class="marker-line" />
            <text x="100" y="95" class="marker-label">T = {{ periodMs }}ms</text>
            
            <!-- Duty cycle annotation -->
            <line x1="0" y1="15" :x2="(dutyCycle/100) * 200" y2="15" class="marker-line on-time" />
            <text :x="Math.max(10, (dutyCycle/100) * 100)" y="10" class="marker-label">{{ onTimeMs }}ms</text>
          </g>
          
          <!-- Voltage labels -->
          <text x="5" y="20" class="voltage-label">5V</text>
          <text x="5" y="65" class="voltage-label">0V</text>
          <text x="370" y="60 - (dutyCycle/100) * 40" 
                class="avg-label">{{ avgVoltage }}V avg</text>
        </svg>
      </div>
      
      <div class="output-container">
        <div class="led-display">
          <div class="led" :style="{ 
            backgroundColor: `rgb(255, ${Math.max(0, 100-brightness*2)}, ${Math.max(0, 100-brightness*2)})`,
            boxShadow: `0 0 ${Math.round(brightness/5)}px ${Math.round(brightness/5)}px rgba(255, 0, 0, 0.7)`,
            opacity: brightness / 100
          }"></div>
          <div class="led-base"></div>
          <div class="power-indicator">
            <div class="power-meter" :style="{ height: `${brightness}%` }"></div>
            <span class="power-label">{{ brightness }}%</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.pwm-demo {
  font-family: Arial, sans-serif;
  max-width: 560px;
  margin: 0 auto;
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.demo-header {
  text-align: center;
  margin-bottom: 10px;
}

h2 {
  color: #333;
  margin: 0 0 5px 0;
  font-size: 16px;
}

.parameters {
  display: flex;
  justify-content: center;
  gap: 20px;
  font-size: 14px;
  color: #555;
}

.visualization-container {
  display: flex;
  background-color: white;
  border-radius: 8px;
  padding: 10px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.waveform-container {
  flex: 3;
}

.waveform {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 4px;
}

.grid-line {
  stroke: #dee2e6;
  stroke-width: 1;
}

.center-line {
  stroke: #adb5bd;
  stroke-width: 1;
  stroke-dasharray: 4 4;
}

.wave-path {
  stroke: #dc3545;
  stroke-width: 3;
  fill: none;
}

.avg-line {
  stroke: #20c997;
  stroke-width: 2;
  stroke-dasharray: 4 4;
}

.marker-line {
  stroke: #6c757d;
  stroke-width: 1;
}

.on-time {
  stroke: #28a745;
}

.marker-label, .voltage-label, .avg-label {
  font-size: 10px;
  fill: #495057;
  text-anchor: middle;
}

.voltage-label {
  text-anchor: start;
}

.avg-label {
  fill: #20c997;
  font-weight: bold;
}

.output-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-evenly;
  margin-left: 10px;
}

.led-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
}

.led {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: red;
  position: relative;
  transition: all 0.3s ease;
}

.led-base {
  width: 45px;
  height: 10px;
  background: linear-gradient(to bottom, #aaa, #ddd);
  border-radius: 0 0 5px 5px;
  margin-top: -5px;
}

.power-indicator {
  width: 12px;
  height: 60px;
  background-color: #e9ecef;
  border: 1px solid #adb5bd;
  border-radius: 6px;
  margin-top: 5px;
  position: relative;
  overflow: hidden;
}

.power-meter {
  position: absolute;
  bottom: 0;
  width: 100%;
  background: linear-gradient(to top, #dc3545, #fd7e14);
  transition: height 0.3s ease;
}

.power-label {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 8px;
  font-weight: bold;
  color: #212529;
}

.motor-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 10px;
}

</style>
