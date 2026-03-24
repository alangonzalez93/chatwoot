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
        () => handleClickOutside(),
        { ignore: ['#property-detail-panel-content', 'dialog'] }
      ]"
      id="property-detail-panel-content"
      class="fixed top-0 ltr:right-0 rtl:left-0 h-full z-40 w-full max-w-3xl bg-n-background ltr:border-l rtl:border-r border-n-weak shadow-lg"
    >
      <!-- Header -->
      <div class="flex items-center justify-between px-4 py-3 border-b border-n-weak">
        <h3 class="font-semibold text-lg text-slate-900 dark:text-slate-100">
          {{ $t('PROPERTIES.DETAIL.TITLE') }}
        </h3>
        <div class="flex items-center gap-1">
          <template v-if="isEditing">
            <Button
              :label="$t('PROPERTIES.DETAIL.CANCEL')"
              icon="i-lucide-x"
              ghost
              sm
              @click="cancelEdit"
            />
            <Button
              :label="$t('PROPERTIES.DETAIL.SAVE')"
              icon="i-lucide-check"
              color="blue"
              sm
              :is-loading="isSaving"
              :disabled="!hasChanges"
              @click="saveChanges"
            />
          </template>
          <Button
            v-else
            icon="i-lucide-pencil"
            ghost
            sm
            v-tooltip.top="$t('PROPERTIES.DETAIL.EDIT')"
            @click="enterEditMode"
          />
          <Button
            icon="i-lucide-x"
            ghost
            sm
            @click="$emit('close')"
          />
        </div>
      </div>

      <!-- Content -->
      <div v-if="property" class="overflow-y-auto h-[calc(100%-60px)] p-4 space-y-4">

        <!-- Property Info -->
        <div class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4">
          <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100 mb-3">
            {{ $t('PROPERTIES.DETAIL.PROPERTY_INFO') }}
          </h4>
          <div class="grid grid-cols-2 gap-x-4 gap-y-5">
            <!-- Internal Code -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.TABLE.INTERNAL_CODE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.internalCode || '-' }}
              </dd>
              <input v-else v-model="editForm.internalCode" type="text" :class="editInputClass" />
            </div>
            <!-- Name -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.PROPERTY_NAME') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.name || '-' }}
              </dd>
              <input v-else v-model="editForm.name" type="text" :class="editInputClass" />
            </div>
            <!-- Address (full width) -->
            <div class="col-span-2">
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.TABLE.ADDRESS') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.address || '-' }}
              </dd>
              <input v-else v-model="editForm.address" type="text" :class="editInputClass" />
            </div>
            <!-- City -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.TABLE.CITY') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.city || '-' }}
              </dd>
              <input v-else v-model="editForm.city" type="text" :class="editInputClass" />
            </div>
            <!-- Province -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.PROVINCE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.province || '-' }}
              </dd>
              <input v-else v-model="editForm.province" type="text" :class="editInputClass" />
            </div>
            <!-- Zone -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ZONE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.zone || '-' }}
              </dd>
              <input v-else v-model="editForm.zone" type="text" :class="editInputClass" />
            </div>
            <!-- Property Unit -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.PROPERTY_UNIT') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.propertyUnit || '-' }}
              </dd>
              <input v-else v-model="editForm.propertyUnit" type="text" :class="editInputClass" />
            </div>
            <!-- Building Name -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.BUILDING_NAME') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.buildingName || '-' }}
              </dd>
              <input v-else v-model="editForm.buildingName" type="text" :class="editInputClass" />
            </div>
            <!-- Rental Status -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.RENTAL_STATUS') }}
              </dt>
              <dd v-if="!isEditing" class="mt-1">
                <span
                  class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                  :class="rentalStatusClass(property.rentalStatus)"
                >
                  {{ rentalStatusLabel(property.rentalStatus) }}
                </span>
              </dd>
              <select v-else v-model="editForm.rentalStatus" :class="editInputClass + ' cursor-pointer'">
                <option value="PENDIENTE">{{ $t('PROPERTIES.RENTAL_STATUS.PENDIENTE') }}</option>
                <option value="EN_ALQUILER">{{ $t('PROPERTIES.RENTAL_STATUS.EN_ALQUILER') }}</option>
                <option value="EN_VENTA">{{ $t('PROPERTIES.RENTAL_STATUS.EN_VENTA') }}</option>
                <option value="EN_ALQUILER_Y_VENTA">{{ $t('PROPERTIES.RENTAL_STATUS.EN_ALQUILER_Y_VENTA') }}</option>
                <option value="VENDIDA">{{ $t('PROPERTIES.RENTAL_STATUS.VENDIDA') }}</option>
                <option value="ALQUILADA">{{ $t('PROPERTIES.RENTAL_STATUS.ALQUILADA') }}</option>
              </select>
            </div>
            <!-- Listed -->
            <div class="flex items-center gap-2">
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.LISTED') }}
              </dt>
              <dd v-if="!isEditing" class="text-sm text-slate-900 dark:text-slate-100">
                {{ property.listed ? '✓' : '✗' }}
              </dd>
              <input v-else v-model="editForm.listed" type="checkbox" class="h-4 w-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500" />
            </div>
            <!-- Notes (full width) -->
            <div class="col-span-2">
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.NOTES') }}
              </dt>
              <dd v-if="!isEditing" class="mt-1 text-sm text-slate-900 dark:text-slate-100 whitespace-pre-wrap">
                {{ property.notes || '-' }}
              </dd>
              <textarea v-else v-model="editForm.notes" rows="3" :class="editInputClass + ' resize-y'" />
            </div>
          </div>
        </div>

        <!-- Owner Info -->
        <div class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4">
          <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100 mb-3">
            {{ $t('PROPERTIES.DETAIL.OWNER_INFO') }}
          </h4>
          <div class="grid grid-cols-2 gap-x-4 gap-y-5">
            <!-- Owner First Name -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.FIRST_NAME') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerFirstName || '-' }}
              </dd>
              <input v-else v-model="editForm.ownerFirstName" type="text" :class="editInputClass" />
            </div>
            <!-- Owner Last Name -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.LAST_NAME') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerLastName || '-' }}
              </dd>
              <input v-else v-model="editForm.ownerLastName" type="text" :class="editInputClass" />
            </div>
            <!-- Owner ID Type -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_TYPE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerIdType || '-' }}
              </dd>
              <input v-else v-model="editForm.ownerIdType" type="text" :class="editInputClass" />
            </div>
            <!-- Owner ID Value -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_VALUE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerIdValue || '-' }}
              </dd>
              <input v-else v-model="editForm.ownerIdValue" type="text" :class="editInputClass" />
            </div>
            <!-- Owner Email -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.EMAIL') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerEmail || '-' }}
              </dd>
              <input v-else v-model="editForm.ownerEmail" type="email" :class="editInputClass" />
            </div>
            <!-- Owner Phone -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.PHONE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.ownerPhone || '-' }}
              </dd>
              <input v-else v-model="editForm.ownerPhone" type="text" :class="editInputClass" />
            </div>
          </div>
        </div>

        <!-- Tenant Info -->
        <div class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4">
          <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100 mb-3">
            {{ $t('PROPERTIES.DETAIL.TENANT_INFO') }}
          </h4>
          <div class="grid grid-cols-2 gap-x-4 gap-y-5">
            <!-- Tenant First Name -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.FIRST_NAME') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantFirstName || '-' }}
              </dd>
              <input v-else v-model="editForm.tenantFirstName" type="text" :class="editInputClass" />
            </div>
            <!-- Tenant Last Name -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.LAST_NAME') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantLastName || '-' }}
              </dd>
              <input v-else v-model="editForm.tenantLastName" type="text" :class="editInputClass" />
            </div>
            <!-- Tenant ID Type -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_TYPE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantIdType || '-' }}
              </dd>
              <input v-else v-model="editForm.tenantIdType" type="text" :class="editInputClass" />
            </div>
            <!-- Tenant ID Value -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.ID_VALUE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantIdValue || '-' }}
              </dd>
              <input v-else v-model="editForm.tenantIdValue" type="text" :class="editInputClass" />
            </div>
            <!-- Tenant Email -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.EMAIL') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantEmail || '-' }}
              </dd>
              <input v-else v-model="editForm.tenantEmail" type="email" :class="editInputClass" />
            </div>
            <!-- Tenant Phone -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.PHONE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.tenantPhone || '-' }}
              </dd>
              <input v-else v-model="editForm.tenantPhone" type="text" :class="editInputClass" />
            </div>
          </div>
        </div>

        <!-- Contract Info -->
        <div
          v-if="isEditing || hasContractData"
          class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4"
        >
          <h4 class="font-semibold text-sm text-slate-900 dark:text-slate-100 mb-3">
            {{ $t('PROPERTIES.DETAIL.CONTRACT_INFO') }}
          </h4>
          <div class="grid grid-cols-2 gap-x-4 gap-y-5">
            <!-- Rent Amount -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.RENT_AMOUNT') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.rentAmount != null ? `$ ${property.rentAmount}` : '-' }}
              </dd>
              <div v-else class="relative mt-4">
                <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-slate-500 dark:text-slate-400">$</span>
                <input v-model.number="editForm.rentAmount" type="number" step="0.01" class="w-full pl-10 pr-2 py-1 text-sm border border-slate-300 dark:border-slate-600 rounded bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-blue-500 [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none" />
              </div>
            </div>
            <!-- Expenses -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.EXPENSES') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.expenses != null ? `$ ${property.expenses}` : '-' }}
              </dd>
              <div v-else class="relative mt-4">
                <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-slate-500 dark:text-slate-400">$</span>
                <input v-model.number="editForm.expenses" type="number" step="0.01" class="w-full pl-10 pr-2 py-1 text-sm border border-slate-300 dark:border-slate-600 rounded bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-blue-500 [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none" />
              </div>
            </div>
            <!-- Rent Amount in Words -->
            <div class="col-span-2">
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.RENT_AMOUNT_WORDS') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.rentAmountInWords || '-' }}
              </dd>
              <input v-else v-model="editForm.rentAmountInWords" type="text" :class="editInputClass" />
            </div>
            <!-- Payment Due Day -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.PAYMENT_DUE_DAY') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.paymentDueDay || '-' }}
              </dd>
              <input v-else v-model.number="editForm.paymentDueDay" type="number" min="1" max="31" :class="editInputClass" />
            </div>
            <!-- Management Fee -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.MANAGEMENT_FEE') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.managementFeePercentage != null ? `${property.managementFeePercentage}%` : '-' }}
              </dd>
              <div v-else class="relative mt-4">
                <input v-model.number="editForm.managementFeePercentage" type="number" step="0.01" class="w-full pl-2 pr-10 py-1 text-sm border border-slate-300 dark:border-slate-600 rounded bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-blue-500 [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none" />
                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-slate-500 dark:text-slate-400">%</span>
              </div>
            </div>
            <!-- Contract Start -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.CONTRACT_START') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.contractStartDate || '-' }}
              </dd>
              <input v-else v-model="editForm.contractStartDate" type="date" :class="editInputClass" />
            </div>
            <!-- Contract End -->
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.CONTRACT_END') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.contractEndDate || '-' }}
              </dd>
              <input v-else v-model="editForm.contractEndDate" type="date" :class="editInputClass" />
            </div>
            <!-- Contract Renewal -->
            <div class="col-span-2">
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.CONTRACT_RENEWAL') }}
              </dt>
              <dd v-if="!isEditing" class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ property.contractRenewalDates || '-' }}
              </dd>
              <input v-else v-model="editForm.contractRenewalDates" type="text" :class="editInputClass" />
            </div>
          </div>
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
            <div class="flex items-center gap-2">
              <Button
                :label="$t('PROPERTIES.ANNUAL_PAYMENT.BUTTON')"
                icon="i-lucide-calendar-plus"
                color="blue"
                variant="outline"
                xs
                @click="openAnnualPaymentDialog(service)"
              />
              <span
                class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                :class="service.active
                  ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                  : 'bg-slate-100 text-slate-800 dark:bg-slate-700 dark:text-slate-200'"
              >
                {{ service.active ? $t('PROPERTIES.STATUS.ACTIVE') : $t('PROPERTIES.STATUS.INACTIVE') }}
              </span>
            </div>
          </div>
          <dl class="space-y-2 mb-3">
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.IDENTIFIER') }}
              </dt>
              <dd class="mt-4 text-sm text-slate-900 dark:text-slate-100">
                {{ service.identifier }}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-slate-500 dark:text-slate-400">
                {{ $t('PROPERTIES.DETAIL.HOLDER') }}
              </dt>
              <dd class="mt-4 text-sm text-slate-900 dark:text-slate-100">
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

      <!-- Annual Payment Dialog -->
      <Dialog
        ref="annualPaymentDialogRef"
        :title="$t('PROPERTIES.ANNUAL_PAYMENT.DIALOG.TITLE')"
        :description="annualPaymentService
          ? $t('PROPERTIES.ANNUAL_PAYMENT.DIALOG.DESCRIPTION', { serviceType: annualPaymentService.serviceType })
          : ''"
        :confirm-button-label="$t('PROPERTIES.ANNUAL_PAYMENT.DIALOG.CONFIRM')"
        :is-loading="isSubmittingPayment"
        @confirm="handleAnnualPayment"
      >
        <div class="space-y-4 mt-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              {{ $t('PROPERTIES.ANNUAL_PAYMENT.DIALOG.AMOUNT') }}
            </label>
            <div class="relative">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-slate-500 dark:text-slate-400">$</span>
              <input
                v-model="annualPaymentAmount"
                type="text"
                inputmode="decimal"
                placeholder="0.00"
                class="w-full pl-10 pr-3 py-2 text-sm border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              {{ $t('PROPERTIES.ANNUAL_PAYMENT.DIALOG.YEAR') }}
            </label>
            <select
              v-model.number="annualPaymentYear"
              class="w-full px-3 py-2 pr-8 text-sm border border-slate-200 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
            >
              <option :value="2026">2026</option>
              <option :value="2027">2027</option>
            </select>
          </div>
        </div>
      </Dialog>
    </div>
  </Transition>
</template>

<script>
import { vOnClickOutside } from '@vueuse/components';
import Button from 'dashboard/components-next/button/Button.vue';
import VouchersTable from './VouchersTable.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import propertiesAPI from '../../../../api/properties';
import { useAlert } from 'dashboard/composables';

const EDITABLE_FIELDS = [
  'internalCode', 'name', 'address', 'city', 'province', 'zone',
  'propertyUnit', 'buildingName', 'notes', 'rentalStatus', 'listed',
  'ownerLastName', 'ownerFirstName', 'ownerIdType',
  'ownerIdValue', 'ownerEmail', 'ownerPhone',
  'tenantLastName', 'tenantFirstName', 'tenantIdType',
  'tenantIdValue', 'tenantEmail', 'tenantPhone',
  'rentAmount', 'rentAmountInWords', 'paymentDueDay',
  'contractStartDate', 'contractRenewalDates', 'contractEndDate',
  'expenses', 'managementFeePercentage',
];

const CONTRACT_FIELDS = [
  'rentAmount', 'rentAmountInWords', 'paymentDueDay',
  'contractStartDate', 'contractRenewalDates', 'contractEndDate',
  'expenses', 'managementFeePercentage',
];

export default {
  name: 'PropertyDetailPanel',
  components: {
    Button,
    VouchersTable,
    Dialog,
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
  emits: ['close', 'property-updated'],
  data() {
    return {
      isEditing: false,
      editForm: {},
      isSaving: false,
      annualPaymentService: null,
      annualPaymentAmount: '',
      annualPaymentYear: 2026,
      isSubmittingPayment: false,
    };
  },
  computed: {
    hasChanges() {
      if (!this.property) return false;
      return EDITABLE_FIELDS.some(field => {
        const original = this.property[field] ?? null;
        let edited = this.editForm[field];
        if (edited === '' || edited === undefined) edited = null;
        // eslint-disable-next-line eqeqeq
        return original != edited && String(original ?? '') !== String(edited ?? '');
      });
    },
    editInputClass() {
      return 'mt-4 w-full px-2 py-1 text-sm border border-slate-300 dark:border-slate-600 rounded bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-blue-500 [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none';
    },
    hasContractData() {
      if (!this.property) return false;
      return CONTRACT_FIELDS.some(field => this.property[field] != null && this.property[field] !== '');
    },
  },
  watch: {
    property() {
      if (this.isEditing) {
        this.cancelEdit();
      }
    },
  },
  methods: {
    enterEditMode() {
      const form = {};
      EDITABLE_FIELDS.forEach(field => {
        const val = this.property[field];
        if (field === 'listed') {
          form[field] = val ?? false;
        } else if (val == null) {
          form[field] = '';
        } else {
          form[field] = val;
        }
      });
      this.editForm = form;
      this.isEditing = true;
    },

    cancelEdit() {
      this.isEditing = false;
      this.editForm = {};
    },

    handleClickOutside() {
      if (this.isEditing) return;
      this.$emit('close');
    },

    buildPatches() {
      const patches = [];
      EDITABLE_FIELDS.forEach(field => {
        const original = this.property[field] ?? null;
        let edited = this.editForm[field];

        // Normalize: empty string → null for API (except booleans)
        if (field !== 'listed' && (edited === '' || edited === undefined)) {
          edited = null;
        }

        // Skip if no change
        // eslint-disable-next-line eqeqeq
        if (original == edited || String(original ?? '') === String(edited ?? '')) {
          return;
        }

        patches.push({
          op: 'replace',
          path: `/${field}`,
          value: edited,
        });
      });
      return patches;
    },

    async saveChanges() {
      const patches = this.buildPatches();
      if (patches.length === 0) {
        useAlert(this.$t('PROPERTIES.DETAIL.NO_CHANGES'));
        return;
      }

      this.isSaving = true;
      try {
        await propertiesAPI.updateProperty(this.property.id, patches);
        useAlert(this.$t('PROPERTIES.DETAIL.SAVE_SUCCESS'));
        this.isEditing = false;
        // Refresh property data
        try {
          const refreshResponse = await propertiesAPI.searchProperties(this.property.internalCode, 0, 1);
          if (refreshResponse.data?.success && refreshResponse.data.content?.length > 0) {
            this.$emit('property-updated', refreshResponse.data.content[0]);
          }
        } catch {
          // Silent refresh error — save was already successful
        }
      } catch (error) {
        const errorMsg = error.response?.data?.message ||
                         error.message ||
                         this.$t('PROPERTIES.DETAIL.SAVE_ERROR');
        useAlert(errorMsg);
      } finally {
        this.isSaving = false;
      }
    },

    rentalStatusLabel(status) {
      const key = `PROPERTIES.RENTAL_STATUS.${status || 'UNKNOWN'}`;
      return this.$t(key);
    },

    rentalStatusClass(status) {
      const classes = {
        PENDIENTE: 'bg-n-amber-3 text-n-amber-11',
        EN_ALQUILER: 'bg-n-blue-3 text-n-blue-11',
        EN_VENTA: 'bg-n-ruby-3 text-n-ruby-11',
        EN_ALQUILER_Y_VENTA: 'bg-n-slate-3 text-n-slate-11',
        VENDIDA: 'bg-n-teal-3 text-n-teal-11',
        ALQUILADA: 'bg-n-teal-3 text-n-teal-11',
      };
      return classes[status] || 'bg-n-slate-3 text-n-slate-11';
    },

    openAnnualPaymentDialog(service) {
      this.annualPaymentService = service;
      this.annualPaymentAmount = '';
      this.annualPaymentYear = 2026;
      this.$refs.annualPaymentDialogRef.open();
    },

    async handleAnnualPayment() {
      const amount = parseFloat(this.annualPaymentAmount);
      if (!amount || amount <= 0) {
        useAlert(this.$t('PROPERTIES.ANNUAL_PAYMENT.VALIDATION.AMOUNT_REQUIRED'));
        return;
      }
      if (!this.annualPaymentYear) {
        useAlert(this.$t('PROPERTIES.ANNUAL_PAYMENT.VALIDATION.YEAR_REQUIRED'));
        return;
      }

      this.isSubmittingPayment = true;
      try {
        const response = await propertiesAPI.registerAnnualPayment(
          this.property.id,
          this.annualPaymentService.serviceType,
          amount,
          this.annualPaymentYear,
        );
        this.$refs.annualPaymentDialogRef.close();
        useAlert(response.data?.message || this.$t('PROPERTIES.ANNUAL_PAYMENT.SUCCESS'));
        try {
          const refreshResponse = await propertiesAPI.searchProperties(this.property.internalCode, 0, 1);
          if (refreshResponse.data?.success && refreshResponse.data.content?.length > 0) {
            this.$emit('property-updated', refreshResponse.data.content[0]);
          }
        } catch {
          // Silent refresh error
        }
      } catch (error) {
        const errorMsg = error.response?.data?.message ||
                         error.message ||
                         this.$t('PROPERTIES.ANNUAL_PAYMENT.ERROR');
        useAlert(errorMsg);
      } finally {
        this.isSubmittingPayment = false;
      }
    },
  },
};
</script>

