<template>
  <v-container class="members__grid my-12">
    <v-row>
      <v-col class="d-flex flex-row align-center">
        <h1 v-if="reqType === 'defaults'" class="f--tertiary grid__title">
          {{
            $i18n.t('communities.members.heading', { community: family.name })
          }}
        </h1>
        <h1 v-else class="f--tertiary grid__title">
          {{
            $i18n.t('communities.invitations.heading', {
              community: family.name
            })
          }}
        </h1>
        <h4 class="f--grey ml-5">
          {{ $i18n.t('communities.members.total', { count: members.length }) }}
        </h4>
      </v-col>
    </v-row>
    <v-row class="mt-3 flex-column flex-md-row">
      <v-col class="col-auto pr-md-0 mr-md-2">
        <Search
          class="members__search"
          :search-term="search"
          @setSearch="filterResults"
        />
      </v-col>
      <v-col class="col-auto d-flex pl-md-0">
        <v-btn
            v-if="canManageCommunity"
            rounded
            outlined
            color="primary"
            elevation="0"
            @click="showInviteModal"
        >
          <v-icon class="pr-2">mdi-plus-circle-outline</v-icon>
          <span>
            {{ $i18n.t('communities.members.invite') }}
          </span>
        </v-btn>
        <v-btn
            v-if="canManageCommunity"
            class="ml-2"
            rounded
            outlined
            color="primary"
            elevation="0"
            @click="showAddOfflineMemberDialog"
        >
          <v-icon class="pr-2">mdi-account-plus-outline</v-icon>
          <span>
            {{ $i18n.t('communities.members.add_offline') }}
          </span>
        </v-btn>
      </v-col>
    </v-row>
    <div
      v-if="isNotificationVisible"
      class="notification__box px-16 py-6"
      :class="isNotificationVisible ? 'close' : ''"
    >
      <div class="notification__mark" />
      <h3 class="d-flex flex-row mb-2">
        <span class="notification__title">
          {{ $i18n.t("communities.members.invitations.title") }}
        </span>
        <v-icon
          class="notification__exit ml-auto mr-0"
          @click="notificationVisible = !notificationVisible"
        >
          mdi-close
        </v-icon>
      </h3>
      <p class="notification__content">
        {{ $i18n.t("communities.members.invitations.description") }}
      </p>
    </div>
    <ListView v-if="isList" :is-invitation="isInvitation" :req-type="reqType" :final-member-list="finalMemberList"/>
    <GridView
        v-else
        :is-invitation="isInvitation"
        :req-type="reqType"
        :final-member-list="finalMemberList"
    />
    <EmptyState v-if="isEmptyInvitation" />
    <FamiliesLoader v-if="isLoading" />
    <infinite-loading
        v-if="hasMorePages"
        spinner="spiral"
        @infinite="loadMore"
    >
      <div slot="no-more" />
    </infinite-loading>
  </v-container>
</template>
<script>
import { mapGetters, mapActions, mapState } from 'vuex'
import FamiliesLoader from '../../components/families/families-loader'
import Search from "../../components/Elements/Forms/Search";
import ListView from "../../components/Community/Members/ListView";
import GridView from "../../components/Community/Members/GridView";
import EmptyState from "../../components/Community/Members/EmptyState";

export default {
  name: 'Members',
  components: {
    GridView,
    ListView,
    Search,
    FamiliesLoader,
    EmptyState
  },
  props: {
    reqType: {
      type: String,
      required: true
    }
  },
  data: () => ({
    finalMemberList: [],
    notificationVisible: true,
    search: ''
  }),
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      members: state => state.members.members,
      family: state => state.families.community,
      viewType: state => state.members.viewType,
    }),
    ...mapGetters({
      isLoading: 'members/isLoading',
      currentPage: 'members/currentPage',
      totalPages: 'members/totalPages',
      flashMessage: 'flashMessage',
    }),
    communityId () {
      return this.$route.params.id
    },
    hasMorePages () {
      return this.currentPage && this.currentPage < this.totalPages
    },
    queryParams () {
      return {
        ...this.filters
      }
    },
    canManageCommunity() {
      return this.$possible('manage', 'Family', { id: this.family.id })
    },
    isInvitation () {
      return this.reqType !== 'defaults'
    },
    isList() {
      return this.viewType !== 'grid'
    },
    isEmptyInvitation() {
      return this.isInvitation && this.finalMemberList.length === 0
    },
    isNotificationVisible() {
      return !this.isLoading && this.notificationVisible && !this.isInvitation && this.finalMemberList.length === 1
    }
  },
  watch: {
    queryParams () {
      this.loadMembersWithFilters()
    },
    reqType () {
      this.loadMembersWithFilters()
    },
    members () {
      if (this.members.length !== this.finalMemberList.length) {
        this.search = ''
        this.finalMemberList = this.members
      }
    }
  },
  created () {
    this.loadMembersWithFilters()
  },
  async mounted () {
    await this.getCommunity({
      id: this.communityId
    })
  },
  methods: {
    ...mapActions({
      getCommunity: 'families/getCommunity',
      loadMembers: 'members/loadNext',
      clearMembers: 'members/clearMembers',
      setDialog: 'layout/setDialog'
    }),
    showInviteModal () {
      this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.family.type }),
        size: 'big',
        component: 'CommunityInviteDialog',
      })
    },
    showAddOfflineMemberDialog () {
      this.setDialog({
        title: this.$i18n.t('communities.members.add_offline'),
        size: 'big',
        component: 'AddOfflineMemberDialog',
      })
    },
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour') ||
        localStorage.getItem('fromStoryTourStep')) {
        result.showcase = true
      }
      return result
    },
    async loadMore ($state) {
      try {
        let payload = {
          'id': this.communityId,
          'type': this.reqType,
          ...this.getShowcaseOptions()
        }
        await this.loadMembers(payload, this.queryParams)
        $state.loaded()
        if (!this.hasMorePages) $state.complete()
      } catch (e) {
        console.error(e)
        $state.complete()
      }
    },
    async loadMembersWithFilters () {
      this.clearMembers()
      let params = { ...this.queryParams, page: 1  }
      let payload = {
        'id': this.communityId,
        'type': this.reqType
      }
      await this.loadMembers(payload, params)
      this.finalMemberList = this.members
    },
    filterResults(search) {
      this.finalMemberList = this.members.filter((member) => {
        const query = search.query.toLowerCase()
        return member.name.toLowerCase().includes(query)
            || member.nickname.toLowerCase().includes(query)
            || member.email.toLowerCase().includes(query)
      })
    }
  }
}
</script>
<style scoped lang="scss">
.members {
  &__grid {
    @include container-grid-size();
  }
  &__search {
    min-width: 260px;
  }
}
.notification {
  &__box {
    position: relative;
    width: 478px;
    height: 114px;
    left: 18em;
    top: 15px;
    background: $color-secondary-lightest;
    border-radius: 5px;
  }
  &__mark {
    position: absolute;
    width: 18px;
    height: 18px;
    top: -9px;
    left: 18px;
    background: $color-secondary-lightest;
    transform: rotate(60deg) skewX(30deg);
  }
  &__title {
    font-family: $title-font;
    font-weight: bold;
    font-size: 18px;
    line-height: 23px;
    color: $color-tertiary;
  }
  &__exit {
    width: 14px;
    height: 13px;
    color: $color-tertiary;
    background: $color-secondary-lightest !important;
  }
  &__content {
    top: 50px;
    left: 35px;
    font-family: $body-font-family;
    font-style: normal;
    font-weight: normal;
    font-size: 16px;
    line-height: 19px;
    color: $color-tertiary;
  }
}
</style>
