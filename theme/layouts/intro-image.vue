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
const style = computed(() => handleBackground(props.image, props.dim))
</script>

<template>
  <div class="slidev-layout w-full h-full intro-image" :style="style">
    <slot />
  </div>
</template>
