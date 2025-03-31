<script setup lang="ts">
import GitHubCard from '../components/GitHubCard.vue';

</script>

<template>
  <div class="grid grid-cols-2 w-full h-full container">
    <div class="slidev-layout default my-auto">
      <slot />
    </div>
    <GitHubCard username="denysvitali"/>
  </div>
</template>

<style scoped>
.container {
    display: flex;
    justify-content: center;
    align-items: center;
}
</style>
