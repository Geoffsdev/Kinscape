<template>
  <v-btn
      fab
      small
      rounded
      outlined
      color="primary"
      elevation="0"
      class="mx-1"
      @click="$router.go(-1)"
  >
    <v-icon>mdi-arrow-left</v-icon>
  </v-btn>
</template>
