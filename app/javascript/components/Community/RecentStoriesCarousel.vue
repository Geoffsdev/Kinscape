<template>
  <div v-if="storiesSimpleList.length" class="stories-carousel">
    <slot>
      <router-link
        :to="{
          name: 'stories',
          query: {
            familyId: communityId,
            authorId,
          },
        }"
        tag="h2"
        class="stories-carousel__title"
      >
        <template v-if="!community">
          {{ $i18n.t("communities.recent_stories.title") }}
        </template>

        <template v-else>{{
          $i18n.t("communities.recent_stories.alternative_title", {
            communityName: community.name,
          })
        }}</template>

      </router-link>
    </slot>
    <div
        v-if="stories.length"
        class="stories-carousel__carousel-wrapper"
    >
      <VueSlickCarousel
          class="mt-7"
          v-bind="settings"
      >
        <div
            ref="sliderItem"
            class="stories-carousel__item"
            v-for="(item, index) in stories"
            :key="index"
        >
          <StoryCard
              :story="item"
              :is-community-profile="true"
          />
        </div>
        <template #prevArrow>
          <button class="slick-arrow slick-prev">
            <v-icon
                class="stories-carousel__arrow-left"
                color="#8B78FE"
                size="64"
            >
              mdi-chevron-left-circle
            </v-icon>
          </button>
        </template>
        <template #nextArrow>
          <button class="slick-arrow slick-next">
            <v-icon
                color="#8B78FE"
                size="64"
            >
              mdi-chevron-right-circle
            </v-icon>
          </button>
        </template>
      </VueSlickCarousel>
    </div>
  </div>
</template>
<script>
import VueSlickCarousel from 'vue-slick-carousel'
import 'vue-slick-carousel/dist/vue-slick-carousel.css'
import 'vue-slick-carousel/dist/vue-slick-carousel-theme.css'
import StoryCard from "../Story/StoryCard";
import { mapState, mapActions } from "vuex";

export default {
  components: {
    StoryCard,
    VueSlickCarousel
  },
  props: {
    communityId: {
      type: String,
      required: true,
    },
    community: {
      type: Object,
      default: () => {}
    },
    authorId: {
      type: String,
      default: null
    },
  },
  computed: {
    ...mapState({
      storiesSimpleList: state => state.stories.simpleList,
    }),
    stories() {
      const stories = this.storiesSimpleList.map((story) => {
        const publication = story.publication
        const family = story.publication.relationships?.family || null

        return {
          ...story,
          community: family,
          publication
        }
      })
      return stories
    },
    settings() {
      return {
        arrows: true,
        dots: true,
        infinite: false,
        slidesToShow: 4,
        slidesToScroll: 4,
        initialSlide: 0,
        responsive: [
          {
            breakpoint: 1900,
            settings: {
              slidesToShow: 3,
              slidesToScroll: 3,
            }
          },
          {
            breakpoint: 1270,
            settings: {
              slidesToShow: 2,
              slidesToScroll: 2,
            }
          },
          {
            breakpoint: 780,
            settings: {
              slidesToShow: 1,
              slidesToScroll: 1
            }
          }
        ]
      }
    }
  },
  mounted() {
    this.getStoriesSimpleList({ familyId: this.communityId, authorId: this.authorId, ...this.getShowcaseOptions() })
  },
  methods: {
    ...mapActions({
      getStoriesSimpleList: 'stories/getStoriesSimpleList',
    }),
    slideNext () {
      this.$refs.slider.$emit('slideNext')
    },
    slidePrev () {
      this.$refs.slider.$emit('slidePre')
    },
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour')) {
        result.showcase = true
      }

      return result
    },
  }
}
</script>
<style scoped lang="scss">
.stories-carousel {
  width:100%;
  margin:20px auto;

  &__title {
    font-family: Enriqueta;
    font-style: normal;
    font-weight: bold;
    font-size: 24px;
    line-height: 32px;
    letter-spacing: -0.02em;
    text-decoration-line: underline;
    position: relative;
    bottom: -10px;
    color: $color-primary;
    cursor: pointer;
    &:hover {
      text-decoration: underline;
    }
  }
  &__slider {
    height: 320px;
  }
  &__carousel-wrapper {
    position: relative;
    left: -11px;
  }
}
::v-deep .slick-arrow {
  z-index: 1;
  width: 64px;
  height: 64px;
}
::v-deep .slick-prev:before, ::v-deep .slick-next:before {
  display: none;
}
::v-deep .slick-disabled {
  display: none;
}
::v-deep .slick-dots {
  & li {
    width: 7px;
    height: 3.62px;
    background: #FCD0C4;
    border-radius: 2px;
  }
  & button {
    display: none;
  }
  & .slick-active {
    width: 24px;
    height: 3.62px;
    background: $color-primary;
    border-radius: 2px;
  }
}
</style>
