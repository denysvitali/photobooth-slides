<script setup lang="ts">
import { computed } from 'vue'
import { handleBackground } from '../layoutHelper'

const props = defineProps({
  image: {
    type: String,
  },
  amount: {
    type: Number,
    default: 3,
  }
})
</script>

<template>
  <div class="grid grid-cols-3 w-full h-full">
    <div class="col-span-2 slidev-layout default">
      <slot />
    </div>
    <img :src="props.image" class="h-full object-contain col-span-1 justify-self-end" />
  </div>
</template>
