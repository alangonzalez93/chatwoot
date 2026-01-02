<template>
  <div class="flex flex-col justify-between flex-1 h-full m-0 overflow-auto bg-n-background px-6">
    <router-view v-slot="{ Component }">
      <component :is="Component" />
    </router-view>
  </div>
</template>

<script>
export default {
  name: 'MiletoBotSettingsWrapper',
};
</script>
