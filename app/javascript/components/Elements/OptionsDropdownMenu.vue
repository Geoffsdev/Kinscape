<template>
  <div>
    <v-menu
      bottom
      offset-y
      :nudge-left="nudgeLeft"
      :nudge-bottom="nudgeBottom"
      v-model="displaySwitcher"
      :content-class="`dropdown-button dropdown-button-${
        theme === 'primary' ? 'primary' : 'secondary'
      }`"
      :close-on-content-click="false"
    >
      <template v-slot:activator="{ on }">
        <div class="dropdown-button__activator" @click="toggleSwitcher">
          <slot name="activator" :v-on="on" />
        </div>
      </template>
      <div
        class="dropdown-button__wrapper"
        :class="`dropdown-button dropdown-button-${
          theme === 'primary' ? 'primary' : 'secondary'
        }`"
      >
        <slot name="content" />
      </div>
    </v-menu>
  </div>
</template>
<script>
export default {
  props: {
    nudgeBottom: {
      type: Number,
      default: 0,
    },
    nudgeLeft: {
      type: Number,
      default: 0,
    },
    theme: {
      type: String,
      default: "primary",
    },
  },
  data: () => ({
    displaySwitcher: false,
  }),
  methods: {
    toggleSwitcher() {
      this.displaySwitcher = !this.displaySwitcher
    },
  },
};
</script>
<style lang="scss" scoped>
.dropdown-button {
  border-radius: 5px;
  box-shadow: none;
  &:before,
  &:after {
    content: "";
    position: absolute;
    width: 0;
    height: 0;
    border-style: solid;
    border-color: transparent;
    border-bottom: 0;
  }
  &:before {
    top: 0;
    right: 20px;
    width: 0;
    height: 0;
    border-left: 8px solid transparent;
    border-right: 8px solid transparent;
  }
  &-primary:before {
    border-bottom: 8px solid $color-primary;
  }
  &-secondary:before {
    border-bottom: 8px solid $color-secondary;
  }
  &:after {
    top: 1px;
    right: 21px;
    width: 0;
    height: 0;
    border-left: 7px solid transparent;
    border-right: 7px solid transparent;
    border-bottom: 7px solid $color-dark-white;
  }
  &__activator {
    display: flex;
    &::v-deep .v-input__slot {
      cursor: pointer !important;
    }
  }
  &__wrapper {
    background: $color-dark-white;
    border-radius: 5px;
    margin-top: 10px;
    overflow: hidden;
    &-primary {
      border: 1px solid $color-primary;
    }
    &-secondary {
      border: 1px solid $color-secondary;
    }
  }
}
</style>
