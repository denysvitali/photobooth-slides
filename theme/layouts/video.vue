<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  video: {
    type: String,
  },
})

const isVisible = ref(false)
let observer: IntersectionObserver | null = null

const videoContainer = ref(null)

onMounted(() => {
  // Use IntersectionObserver to detect when the component is visible
  observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      isVisible.value = entry.isIntersecting
    })
  }, {
    threshold: 0.1 // 10% visibility triggers the callback
  })
  
  if (videoContainer.value) {
    observer.observe(videoContainer.value)
  }
})

onUnmounted(() => {
  // Clean up the observer
  if (observer) {
    observer.disconnect()
  }
  isVisible.value = false
})
</script>

<style scoped>
</style>

<template>
    <div class="slidev-layout default video" ref="videoContainer">
        <div class="my-auto absolute z-10">
            <slot />
        </div>
        <iframe 
            v-if="isVisible"
            class="absolute top-0 left-0 w-full h-full"
            :src="`https://www.youtube.com/embed/${ props.video }?autoplay=1&mute=1&controls=0&showinfo=0&rel=0&enablejsapi=1&loop=1&playlist=${ props.video }`"
            frameborder="0"
            allowfullscreen
        />
    </div>
</template>
