<template>
  <div class="py-4">
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="mb-6">
        <h2 class="text-2xl font-semibold text-slate-900 dark:text-slate-100">
          {{ $t('MILETO_BOT.HEADER') }}
        </h2>
        <p class="mt-2 text-sm text-slate-600 dark:text-slate-400">
          {{ $t('MILETO_BOT.DESCRIPTION') }}
        </p>
      </div>

      <!-- Loading State -->
      <div v-if="uiFlags.isFetching" class="flex justify-center items-center py-12">
        <spinner size="large" />
      </div>

      <!-- Bot Toggle Card -->
      <div
        v-else
        class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4 sm:p-6"
      >
        <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
          <div class="flex-1">
            <div class="flex flex-wrap items-center gap-2 sm:gap-3 mb-2">
              <fluent-icon
                icon="bot"
                size="24"
                class="text-n-brand flex-shrink-0"
              />
              <h3 class="text-lg font-medium text-slate-900 dark:text-slate-100">
                {{ $t('MILETO_BOT.BOT_STATUS') }}
              </h3>
              <span
                v-if="botEnabled"
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
              >
                {{ $t('MILETO_BOT.STATUS.ACTIVE') }}
              </span>
              <span
                v-else
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-800 dark:bg-slate-700 dark:text-slate-200"
              >
                {{ $t('MILETO_BOT.STATUS.INACTIVE') }}
              </span>
            </div>

            <p class="text-sm text-slate-600 dark:text-slate-400">
              {{ $t('MILETO_BOT.BOT_DESCRIPTION') }}
            </p>
          </div>

          <!-- Toggle Switch -->
          <div class="flex items-center justify-end sm:justify-start sm:ml-4">
            <label class="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                :checked="botEnabled"
                :disabled="uiFlags.isUpdating"
                class="sr-only peer"
                @change="toggleBot"
              />
              <div
                class="w-11 h-6 bg-slate-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-slate-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-slate-600 peer-checked:bg-n-brand"
                :class="{ 'opacity-50 cursor-not-allowed': uiFlags.isUpdating }"
              />
            </label>
          </div>
        </div>

        <!-- Updating indicator -->
        <div
          v-if="uiFlags.isUpdating"
          class="mt-3 flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400"
        >
          <spinner size="small" />
          <span>{{ $t('MILETO_BOT.UPDATING') }}</span>
        </div>
      </div>

      <!-- Info Box -->
      <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
        <div class="flex gap-3">
          <fluent-icon icon="info" size="20" class="text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5" />
          <div class="text-sm text-blue-700 dark:text-blue-300">
            <p class="font-medium mb-1">{{ $t('MILETO_BOT.INFO.TITLE') }}</p>
            <p>{{ $t('MILETO_BOT.INFO.MESSAGE') }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Spinner from 'shared/components/Spinner.vue';
import miletoBot from '../../../api/miletoBot';
import { useAlert } from 'dashboard/composables';

export default {
  name: 'MiletoBotSettings',
  components: {
    Spinner,
  },
  data() {
    return {
      botEnabled: false,
      uiFlags: {
        isFetching: false,
        isUpdating: false,
      },
    };
  },
  computed: {
    ...mapGetters({
      currentAccountId: 'getCurrentAccountId',
      currentUser: 'getCurrentUser',
    }),
    isAdmin() {
      return this.currentUser?.role === 'administrator';
    },
  },
  mounted() {
    this.fetchBotStatus();
  },
  methods: {
    async fetchBotStatus() {
      this.uiFlags.isFetching = true;
      try {
        const response = await miletoBot.getBotStatus();
        this.botEnabled = response.data?.botEnabled || false;
      } catch (error) {
        useAlert(this.$t('MILETO_BOT.API.ERROR.FETCH'));
        console.error('Error fetching Mileto bot status:', error);
      } finally {
        this.uiFlags.isFetching = false;
      }
    },
    async toggleBot() {
      if (!this.isAdmin) {
        useAlert(this.$t('MILETO_BOT.API.ERROR.PERMISSION'));
        return;
      }

      const newStatus = !this.botEnabled;
      this.uiFlags.isUpdating = true;

      try {
        await miletoBot.toggleBot(newStatus);

        // Update local state
        this.botEnabled = newStatus;

        const message = newStatus
          ? this.$t('MILETO_BOT.API.SUCCESS.ACTIVATED')
          : this.$t('MILETO_BOT.API.SUCCESS.DEACTIVATED');

        useAlert(message);
      } catch (error) {
        useAlert(this.$t('MILETO_BOT.API.ERROR.UPDATE'));
        console.error('Error updating Mileto bot:', error);
      } finally {
        this.uiFlags.isUpdating = false;
      }
    },
  },
};
</script>
