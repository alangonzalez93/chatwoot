<template>
  <div class="py-4">
    <div class="mx-auto" style="max-width: 1400px;">
      <!-- Header -->
      <div class="mb-6 flex justify-between items-center">
        <div>
          <h2 class="text-2xl font-semibold text-slate-900 dark:text-slate-100">
            {{ $t('PROPERTIES.HEADER') }}
          </h2>
          <p class="mt-1 text-sm text-slate-600 dark:text-slate-400">
            {{ $t('PROPERTIES.DESCRIPTION') }}
          </p>
        </div>

        <div class="flex gap-2">
          <!-- Sync Taxes Button -->
          <Button
            :label="$t('PROPERTIES.SYNC.BUTTON')"
            icon="i-lucide-refresh-cw"
            color="slate"
            variant="outline"
            @click="openSyncDialog"
          />
          <!-- Export Button -->
          <Button
            :label="isExporting ? $t('PROPERTIES.EXPORT.GENERATING') : $t('PROPERTIES.EXPORT.BUTTON')"
            icon="i-lucide-download"
            color="slate"
            variant="outline"
            :is-loading="isExporting"
            :disabled="isExporting"
            @click="openExportDialog"
          />
          <!-- Import Button -->
          <Button
            :label="$t('PROPERTIES.IMPORT.BUTTON')"
            icon="i-lucide-upload"
            color="blue"
            @click="openImportDialog"
          />
        </div>
      </div>

      <!-- Search Bar -->
      <div class="mb-4 flex gap-2">
        <input
          v-model="searchQuery"
          type="text"
          :placeholder="$t('PROPERTIES.SEARCH.PLACEHOLDER')"
          class="flex-1 px-3 py-2 text-sm border border-slate-200 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
          @keydown.enter="handleSearch"
        />
        <MultiSelect
          v-model="selectedRentalStatuses"
          :options="rentalStatusOptions"
          :max-chips="2"
        />
        <Button
          :label="$t('PROPERTIES.SEARCH.BUTTON')"
          icon="i-lucide-search"
          color="blue"
          @click="handleSearch"
        />
        <Button
          v-if="isSearchMode"
          :label="$t('PROPERTIES.SEARCH.CLEAR')"
          icon="i-lucide-x"
          color="slate"
          variant="outline"
          @click="clearSearch"
        />
      </div>

      <!-- Loading State -->
      <div v-if="uiFlags.isFetching" class="flex justify-center items-center py-12">
        <spinner size="large" />
      </div>

      <!-- Empty State -->
      <div v-else-if="!properties.length" class="text-center py-12">
        <p class="text-slate-600 dark:text-slate-400">
          {{ $t('PROPERTIES.EMPTY_STATE') }}
        </p>
      </div>

      <!-- Properties Table -->
      <div v-else class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-slate-200 dark:divide-slate-700">
            <thead class="bg-slate-50 dark:bg-slate-900">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  {{ $t('PROPERTIES.TABLE.INTERNAL_CODE') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  {{ $t('PROPERTIES.TABLE.ADDRESS') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  {{ $t('PROPERTIES.TABLE.CITY') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  {{ $t('PROPERTIES.TABLE.OWNER') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  {{ $t('PROPERTIES.TABLE.TENANT') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  {{ $t('PROPERTIES.TABLE.STATUS') }}
                </th>
                <th class="px-6 py-3 text-right text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  {{ $t('PROPERTIES.TABLE.ACTIONS') }}
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-slate-800 divide-y divide-slate-200 dark:divide-slate-700">
              <tr
                v-for="property in properties"
                :key="property.id"
                class="hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"
              >
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-slate-900 dark:text-slate-100">
                  {{ property.internalCode }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600 dark:text-slate-400">
                  {{ property.address }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600 dark:text-slate-400">
                  {{ property.city }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600 dark:text-slate-400">
                  {{ property.ownerName || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600 dark:text-slate-400">
                  {{ property.tenantName || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    :class="rentalStatusClass(property.rentalStatus)"
                  >
                    {{ rentalStatusLabel(property.rentalStatus) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <Button
                    v-tooltip.top="$t('PROPERTIES.VIEW_DETAILS')"
                    icon="i-lucide-eye"
                    slate
                    xs
                    faded
                    @click="openPropertyDetails(property)"
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <PaginationFooter
          v-if="totalItems > 0"
          :current-page="currentPage + 1"
          :total-items="totalItems"
          :items-per-page="pageSize"
          @update:current-page="handlePageChange"
        />
      </div>
    </div>

    <!-- Property Detail Panel -->
    <PropertyDetailPanel
      :property="selectedProperty"
      :is-open="isPanelOpen"
      @close="closePropertyDetails"
      @property-updated="onPropertyUpdated"
    />

    <!-- Property Import Dialog -->
    <PropertyImportDialog
      ref="propertyImportDialogRef"
      @import="onImport"
    />

    <!-- Sync Taxes Dialog -->
    <Dialog
      ref="syncDialogRef"
      :title="$t('PROPERTIES.SYNC.DIALOG.TITLE')"
      :description="$t('PROPERTIES.SYNC.DIALOG.DESCRIPTION')"
      :confirm-button-label="$t('PROPERTIES.SYNC.DIALOG.CONFIRM')"
      :is-loading="isSyncing"
      @confirm="handleSync"
    />

    <!-- Export Dialog -->
    <Dialog
      ref="exportDialogRef"
      :title="$t('PROPERTIES.EXPORT.DIALOG.TITLE')"
      :description="$t('PROPERTIES.EXPORT.DIALOG.DESCRIPTION')"
      :confirm-button-label="$t('PROPERTIES.EXPORT.DIALOG.CONFIRM')"
      :is-loading="isExporting"
      @confirm="handleExport"
    >
      <div class="space-y-4 mt-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
            {{ $t('PROPERTIES.EXPORT.DIALOG.MONTH') }}
          </label>
          <select
            v-model.number="exportMonth"
            class="w-full px-3 py-2 pr-8 text-sm border border-slate-200 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
          >
            <option v-for="m in months" :key="m.value" :value="m.value">
              {{ m.label }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
            {{ $t('PROPERTIES.EXPORT.DIALOG.YEAR') }}
          </label>
          <select
            v-model.number="exportYear"
            class="w-full px-3 py-2 pr-8 text-sm border border-slate-200 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
          >
            <option :value="2026">2026</option>
            <option :value="2027">2027</option>
          </select>
        </div>
      </div>
    </Dialog>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Spinner from 'shared/components/Spinner.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import PaginationFooter from 'dashboard/components-next/pagination/PaginationFooter.vue';
import propertiesAPI from '../../../api/properties';
import { useAlert } from 'dashboard/composables';
import { downloadBinaryFile } from '../../../helper/downloadHelper';
import PropertyDetailPanel from './components/PropertyDetailPanel.vue';
import MultiSelect from 'dashboard/components-next/filter/inputs/MultiSelect.vue';
import PropertyImportDialog from './components/PropertyImportDialog.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

export default {
  name: 'PropertiesIndex',
  components: {
    Spinner,
    Button,
    PaginationFooter,
    PropertyDetailPanel,
    PropertyImportDialog,
    Dialog,
    MultiSelect,
  },
  data() {
    return {
      properties: [],
      selectedProperty: null,
      isPanelOpen: false,
      isExporting: false,
      isSyncing: false,
      exportMonth: new Date().getMonth() + 1,
      exportYear: new Date().getFullYear(),
      searchQuery: '',
      selectedRentalStatuses: [],
      isSearchMode: false,
      currentPage: 0,
      totalItems: 0,
      totalPages: 0,
      pageSize: 20,
      uiFlags: {
        isFetching: false,
      },
    };
  },
  computed: {
    ...mapGetters({
      currentAccountId: 'getCurrentAccountId',
      currentUser: 'getCurrentUser',
    }),
    months() {
      return Array.from({ length: 12 }, (_, i) => ({
        value: i + 1,
        label: this.$t(`PROPERTIES.EXPORT.MONTHS.${i + 1}`),
      }));
    },
    rentalStatusOptions() {
      return [
        { id: 'PENDIENTE', name: this.$t('PROPERTIES.RENTAL_STATUS.PENDIENTE') },
        { id: 'EN_ALQUILER', name: this.$t('PROPERTIES.RENTAL_STATUS.EN_ALQUILER') },
        { id: 'EN_VENTA', name: this.$t('PROPERTIES.RENTAL_STATUS.EN_VENTA') },
        { id: 'EN_ALQUILER_Y_VENTA', name: this.$t('PROPERTIES.RENTAL_STATUS.EN_ALQUILER_Y_VENTA') },
        { id: 'VENDIDA', name: this.$t('PROPERTIES.RENTAL_STATUS.VENDIDA') },
        { id: 'ALQUILADA', name: this.$t('PROPERTIES.RENTAL_STATUS.ALQUILADA') },
      ];
    },
  },
  mounted() {
    this.fetchProperties();
  },
  methods: {
    async fetchProperties(page = 0) {
      this.uiFlags.isFetching = true;
      try {
        const response = await propertiesAPI.getProperties(page, this.pageSize);

        if (response.data.success) {
          this.properties = response.data.content || [];
          this.totalItems = response.data.totalItems || 0;
          this.totalPages = response.data.totalPages || 0;
          this.currentPage = response.data.currentPage || 0;
          this.pageSize = response.data.pageSize || 20;
        } else {
          useAlert(this.$t('PROPERTIES.API.ERROR.FETCH'));
        }
      } catch (error) {
        useAlert(this.$t('PROPERTIES.API.ERROR.FETCH'));
        console.error('Error fetching properties:', error);
      } finally {
        this.uiFlags.isFetching = false;
      }
    },

    handlePageChange(page) {
      // PaginationFooter usa páginas 1-indexed, API usa 0-indexed
      if (this.isSearchMode) {
        this.fetchSearchResults(this.searchQuery.trim(), page - 1);
      } else {
        this.fetchProperties(page - 1);
      }
    },

    handleSearch() {
      const hasText = this.searchQuery.trim().length > 0;
      const hasStatus = this.selectedRentalStatuses.length > 0;
      if (!hasText && !hasStatus) {
        this.clearSearch();
        return;
      }
      this.isSearchMode = true;
      this.fetchSearchResults(this.searchQuery.trim(), 0);
    },

    clearSearch() {
      this.searchQuery = '';
      this.selectedRentalStatuses = [];
      this.isSearchMode = false;
      this.fetchProperties(0);
    },

    async fetchSearchResults(text, page = 0) {
      this.uiFlags.isFetching = true;
      const rentalStatus = this.selectedRentalStatuses.length > 0
        ? this.selectedRentalStatuses.map(s => s.id).join(',')
        : null;
      try {
        const response = await propertiesAPI.searchProperties(text, page, this.pageSize, rentalStatus);
        if (response.data.success) {
          this.properties = response.data.content || [];
          this.totalItems = response.data.totalItems || 0;
          this.totalPages = response.data.totalPages || 0;
          this.currentPage = response.data.currentPage || 0;
          this.pageSize = response.data.pageSize || 20;
        } else {
          useAlert(this.$t('PROPERTIES.API.ERROR.FETCH'));
        }
      } catch (error) {
        useAlert(this.$t('PROPERTIES.API.ERROR.FETCH'));
        console.error('Error searching properties:', error);
      } finally {
        this.uiFlags.isFetching = false;
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

    openPropertyDetails(property) {
      this.selectedProperty = property;
      this.isPanelOpen = true;
    },

    onPropertyUpdated(updatedProperty) {
      this.selectedProperty = updatedProperty;
      const index = this.properties.findIndex(p => p.id === updatedProperty.id);
      if (index !== -1) {
        this.properties.splice(index, 1, updatedProperty);
      }
    },

    closePropertyDetails() {
      this.isPanelOpen = false;
      // Delay para que termine la animación antes de limpiar
      setTimeout(() => {
        this.selectedProperty = null;
      }, 300);
    },

    openSyncDialog() {
      this.$refs.syncDialogRef.open();
    },

    async handleSync() {
      this.isSyncing = true;
      try {
        await propertiesAPI.syncTaxes();
        this.$refs.syncDialogRef.close();
        useAlert(this.$t('PROPERTIES.SYNC.SUCCESS'));
      } catch (error) {
        this.$refs.syncDialogRef.close();
        const errorMsg = error.response?.data?.message ||
                         error.message ||
                         this.$t('PROPERTIES.SYNC.ERROR');
        useAlert(errorMsg);
      } finally {
        this.isSyncing = false;
      }
    },

    openImportDialog() {
      this.$refs.propertyImportDialogRef?.dialogRef.open();
    },

    openExportDialog() {
      this.exportMonth = new Date().getMonth() + 1;
      this.exportYear = new Date().getFullYear();
      this.$refs.exportDialogRef.open();
    },

    async handleExport() {
      this.isExporting = true;
      try {
        const response = await propertiesAPI.exportReceipts(this.exportMonth, this.exportYear);
        const monthLabel = this.$t(`PROPERTIES.EXPORT.MONTHS.${this.exportMonth}`).toLowerCase();
        downloadBinaryFile(`recibos-${monthLabel}-${this.exportYear}.xlsx`, response.data);
        this.$refs.exportDialogRef.close();
      } catch (error) {
        const errorMsg = error.response?.data?.message ||
                         error.message ||
                         this.$t('PROPERTIES.EXPORT.ERROR');
        useAlert(errorMsg);
      } finally {
        this.isExporting = false;
      }
    },

    async onImport(file) {
      try {
        const response = await propertiesAPI.importProperties(file);

        // Cerrar dialog
        this.$refs.propertyImportDialogRef?.dialogRef.close();

        // Parsear response
        const { success, totalRows, propertiesCreated, propertiesUpdated, servicesCreated, errors } = response.data;

        if (success) {
          // Mensaje de éxito con estadísticas detalladas
          const message = this.$t('PROPERTIES.IMPORT.SUCCESS', {
            total: totalRows,
            created: propertiesCreated,
            updated: propertiesUpdated,
            services: servicesCreated,
          });
          useAlert(message);

          // Refrescar tabla (página actual)
          this.fetchProperties(this.currentPage);
        } else {
          // Mostrar errores si los hay
          const errorMessage = errors.length > 0
            ? errors.join(', ')
            : this.$t('PROPERTIES.IMPORT.ERROR');
          useAlert(errorMessage);
        }
      } catch (error) {
        // Error de red o validación
        const errorMsg = error.response?.data?.message ||
                         error.message ||
                         this.$t('PROPERTIES.IMPORT.ERROR');
        useAlert(errorMsg);
      }
    },
  },
};
</script>
