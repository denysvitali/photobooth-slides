<script setup lang="ts">
import { computed } from 'vue'
import { handleBackground } from '../layoutHelper'

const props = defineProps({
  image: {
    type: String,
  },
  dim: {
    type: Boolean,
  }
})
const style = computed(() => handleBackground(props.image, props.dim, 'contain'))
</script>

<template>
  <div class="relative top-0 left-0 bottom-0 right-0 w-full h-full">
    <div class="slidev-layout w-full absolute z-101 slide-text">
      <slot/>
    </div>
    <img 
      :src="props.image"
      class="absolute w-full h-full z-100"
    />
  </div>
</template>


<style>
.slide-text h1 {
  text-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
}
</style>
