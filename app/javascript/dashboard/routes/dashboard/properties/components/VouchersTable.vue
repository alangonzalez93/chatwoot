<script setup>
import { h } from 'vue';
import {
  useVueTable,
  createColumnHelper,
  getCoreRowModel,
} from '@tanstack/vue-table';
import { useI18n } from 'vue-i18n';
import { format } from 'date-fns';
import Table from 'dashboard/components/table/Table.vue';

const props = defineProps({
  vouchers: {
    type: Array,
    default: () => [],
  },
});

const { t } = useI18n();

// Format currency for Argentina locale (ARS)
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('es-AR', {
    style: 'currency',
    currency: 'ARS',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount || 0);
};

// Format date for Argentina locale (dd/MM/yyyy)
const formatDate = (dateString) => {
  if (!dateString) return '---';
  try {
    const date = new Date(dateString);
    return format(date, 'dd/MM/yyyy');
  } catch (e) {
    return '---';
  }
};

// Default text cell renderer
const defaultSpanRender = (cellProps) =>
  h(
    'span',
    {
      class: cellProps.getValue()
        ? 'text-n-slate-12'
        : 'text-n-slate-11',
    },
    cellProps.getValue() ? cellProps.getValue() : '---'
  );

// Currency cell renderer with tabular numbers
const currencyRender = (cellProps) =>
  h(
    'span',
    {
      class: 'text-n-slate-12 font-medium tabular-nums',
    },
    formatCurrency(cellProps.getValue())
  );

// Date cell renderer with tabular numbers
const dateRender = (cellProps) =>
  h(
    'span',
    {
      class: 'text-n-slate-12 tabular-nums',
    },
    formatDate(cellProps.getValue())
  );

// Define table columns
const columnHelper = createColumnHelper();
const columns = [
  columnHelper.accessor('period', {
    header: t('PROPERTIES.VOUCHERS.TABLE.PERIOD'),
    cell: defaultSpanRender,
    size: 120,
  }),
  columnHelper.accessor('dueDate', {
    header: t('PROPERTIES.VOUCHERS.TABLE.DUE_DATE'),
    cell: dateRender,
    size: 110,
  }),
  columnHelper.accessor('baseAmount', {
    header: t('PROPERTIES.VOUCHERS.TABLE.BASE_AMOUNT'),
    cell: currencyRender,
    size: 120,
  }),
  columnHelper.accessor('interests', {
    header: t('PROPERTIES.VOUCHERS.TABLE.INTERESTS'),
    cell: currencyRender,
    size: 110,
  }),
  columnHelper.accessor('discounts', {
    header: t('PROPERTIES.VOUCHERS.TABLE.DISCOUNTS'),
    cell: currencyRender,
    size: 110,
  }),
  columnHelper.accessor('total', {
    header: t('PROPERTIES.VOUCHERS.TABLE.TOTAL'),
    cell: currencyRender,
    size: 120,
  }),
];

// Create table instance
const table = useVueTable({
  get data() {
    return props.vouchers;
  },
  columns,
  enableSorting: false,
  getCoreRowModel: getCoreRowModel(),
});
</script>

<template>
  <div class="vouchers-table-container">
    <div v-if="vouchers.length > 0" class="overflow-x-auto">
      <Table
        :table="table"
        type="compact"
        class="w-full"
      />
    </div>
    <p v-else class="text-xs text-slate-500 dark:text-slate-400 italic">
      {{ $t('PROPERTIES.DETAIL.NO_PENDING_VOUCHERS') }}
    </p>
  </div>
</template>
