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

        <!-- Import Button -->
        <Button
          :label="$t('PROPERTIES.IMPORT.BUTTON')"
          icon="i-lucide-upload"
          color="blue"
          @click="openImportDialog"
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
                    :class="property.active
                      ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                      : 'bg-slate-100 text-slate-800 dark:bg-slate-700 dark:text-slate-200'"
                  >
                    {{ property.active ? $t('PROPERTIES.STATUS.ACTIVE') : $t('PROPERTIES.STATUS.INACTIVE') }}
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
    />

    <!-- Property Import Dialog -->
    <PropertyImportDialog
      ref="propertyImportDialogRef"
      @import="onImport"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Spinner from 'shared/components/Spinner.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import PaginationFooter from 'dashboard/components-next/pagination/PaginationFooter.vue';
import propertiesAPI from '../../../api/properties';
import { useAlert } from 'dashboard/composables';
import PropertyDetailPanel from './components/PropertyDetailPanel.vue';
import PropertyImportDialog from './components/PropertyImportDialog.vue';

export default {
  name: 'PropertiesIndex',
  components: {
    Spinner,
    Button,
    PaginationFooter,
    PropertyDetailPanel,
    PropertyImportDialog,
  },
  data() {
    return {
      properties: [],
      selectedProperty: null,
      isPanelOpen: false,
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
      this.fetchProperties(page - 1);
    },

    openPropertyDetails(property) {
      this.selectedProperty = property;
      this.isPanelOpen = true;
    },

    closePropertyDetails() {
      this.isPanelOpen = false;
      // Delay para que termine la animación antes de limpiar
      setTimeout(() => {
        this.selectedProperty = null;
      }, 300);
    },

    openImportDialog() {
      this.$refs.propertyImportDialogRef?.dialogRef.open();
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
