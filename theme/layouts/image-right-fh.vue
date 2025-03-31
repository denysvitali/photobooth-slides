<script setup lang="ts">
import { computed } from 'vue'
import { handleBackground } from '../layoutHelper'

const props = defineProps({
  image: {
    type: String,
  },
  class: {
    type: String,
  },
  size: {
    type: String,
    default: 'cover',
  },
  position: {
    type: String,
    default: 'center',
  }
})
const style = computed(() => handleBackground(props.image, false, props.size, props.position))
</script>

<template>
  <div class="grid grid-cols-2 w-full h-full">
    <div class="slidev-layout default image-right" :class="props.class">
      <slot />
    </div>
    <div :style="style" />
  </div>
</template>
