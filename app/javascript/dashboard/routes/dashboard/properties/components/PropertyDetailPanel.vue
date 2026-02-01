<template>
  <Transition
    enter-active-class="transition-transform duration-300 ease-in-out"
    enter-from-class="ltr:translate-x-full rtl:-translate-x-full"
    enter-to-class="ltr:translate-x-0 rtl:-translate-x-0"
    leave-active-class="transition-transform duration-300 ease-in-out"
    leave-from-class="ltr:translate-x-0 rtl:-translate-x-0"
    leave-to-class="ltr:translate-x-full rtl:-translate-x-full"
  >
    <div
      v-if="isOpen"
      v-on-click-outside="[
        () => $emit('close'),
        { ignore: ['#property-detail-panel-content'] }
      ]"
      id="property-detail-panel-content"
      class="fixed top-0 ltr:right-0 rtl:left-0 h-full z-40 w-full max-w-3xl bg-n-background ltr:border-l rtl:border-r border-n-weak shadow-lg"
    >
      <!-- Header -->
      <div class="flex items-center justify-between px-4 py-3 border-b border-n-weak">
        <h3 class="font-semibold text-lg text-slate-900 dark:text-slate-100">
          {{ $t('PROPERTIES.DETAIL.TITLE') }}
        </h3>
        <Button
          icon="i-lucide-x"
          ghost
          sm
          @click="$emit('close')"
        />
      </div>

      <!-- Content -->
      <div v-if="property" class="overflow-y-auto h-[calc(100%-60px)] p-4 space-y-6">
      <!-- Property Info -->
      <div class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4">
        <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100 mb-3">
          {{ $t('PROPERTIES.DETAIL.PROPERTY_INFO') }}
        </h4>
        <dl class="space-y-2">
          <div>
            <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
              {{ $t('PROPERTIES.TABLE.INTERNAL_CODE') }}
            </dt>
            <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
              {{ property.internalCode }}
            </dd>
          </div>
          <div>
            <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
              {{ $t('PROPERTIES.TABLE.ADDRESS') }}
            </dt>
            <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
              {{ property.address }}
            </dd>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.TABLE.CITY') }}
              </dt>
              <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
                {{ property.city }}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.PROVINCE') }}
              </dt>
              <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
                {{ property.province }}
              </dd>
            </div>
          </div>
        </dl>
      </div>

      <!-- Owner Info -->
      <div class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4">
        <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100 mb-3">
          {{ $t('PROPERTIES.DETAIL.OWNER_INFO') }}
        </h4>
        <dl class="space-y-2">
          <div>
            <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
              {{ $t('PROPERTIES.DETAIL.NAME') }}
            </dt>
            <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
              {{ property.ownerName || '-' }}
            </dd>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_TYPE') }}
              </dt>
              <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerIdType || '-' }}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_VALUE') }}
              </dt>
              <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerIdValue || '-' }}
              </dd>
            </div>
          </div>
        </dl>
      </div>

      <!-- Tenant Info -->
      <div class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4">
        <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100 mb-3">
          {{ $t('PROPERTIES.DETAIL.TENANT_INFO') }}
        </h4>
        <dl class="space-y-2">
          <div>
            <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
              {{ $t('PROPERTIES.DETAIL.NAME') }}
            </dt>
            <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
              {{ property.tenantName || '-' }}
            </dd>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_TYPE') }}
              </dt>
              <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantIdType || '-' }}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_VALUE') }}
              </dt>
              <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantIdValue || '-' }}
              </dd>
            </div>
          </div>
        </dl>
      </div>

      <!-- Services/Taxes -->
      <div
        v-for="service in property.services"
        :key="service.id"
        class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4"
      >
        <div class="flex items-center justify-between mb-3">
          <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100">
            {{ service.serviceType }}
          </h4>
          <span
            class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
            :class="service.active
              ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
              : 'bg-slate-100 text-slate-800 dark:bg-slate-700 dark:text-slate-200'"
          >
            {{ service.active ? $t('PROPERTIES.STATUS.ACTIVE') : $t('PROPERTIES.STATUS.INACTIVE') }}
          </span>
        </div>
        <dl class="space-y-2 mb-3">
          <div>
            <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
              {{ $t('PROPERTIES.DETAIL.IDENTIFIER') }}
            </dt>
            <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
              {{ service.identifier }}
            </dd>
          </div>
          <div>
            <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
              {{ $t('PROPERTIES.DETAIL.HOLDER') }}
            </dt>
            <dd class="mt-1 text-sm text-slate-900 dark:text-slate-100">
              {{ service.holder }}
            </dd>
          </div>
        </dl>

        <!-- Current Vouchers -->
        <div>
          <h5 class="text-xs font-semibold text-slate-700 dark:text-slate-300 mb-3">
            {{ $t('PROPERTIES.DETAIL.PENDING_VOUCHERS') }}
          </h5>
          <VouchersTable :vouchers="service.currentVouchers || []" />
        </div>
      </div>
      </div>
    </div>
  </Transition>
</template>

<script>
import { vOnClickOutside } from '@vueuse/components';
import Button from 'dashboard/components-next/button/Button.vue';
import VouchersTable from './VouchersTable.vue';

export default {
  name: 'PropertyDetailPanel',
  components: {
    Button,
    VouchersTable,
  },
  directives: {
    onClickOutside: vOnClickOutside,
  },
  props: {
    property: {
      type: Object,
      default: null,
    },
    isOpen: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['close'],
};
</script>
