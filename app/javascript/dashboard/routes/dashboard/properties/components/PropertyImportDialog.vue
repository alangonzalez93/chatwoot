<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const emit = defineEmits(['import']);
const { t } = useI18n();

const dialogRef = ref(null);
const fileInput = ref(null);
const hasSelectedFile = ref(null);
const selectedFileName = ref('');
const isImporting = ref(false);

const handleFileClick = () => fileInput.value?.click();

const processFileName = fileName => {
  const lastDotIndex = fileName.lastIndexOf('.');
  const extension = fileName.slice(lastDotIndex);
  const baseName = fileName.slice(0, lastDotIndex);

  return baseName.length > 20
    ? `${baseName.slice(0, 20)}...${extension}`
    : fileName;
};

const handleFileChange = () => {
  const file = fileInput.value?.files[0];

  // Validar tipo de archivo
  if (file && !file.name.endsWith('.xlsx')) {
    useAlert(t('PROPERTIES.IMPORT.INVALID_FILE_TYPE'));
    fileInput.value.value = null;
    return;
  }

  hasSelectedFile.value = file;
  selectedFileName.value = file ? processFileName(file.name) : '';
};

const handleRemoveFile = () => {
  hasSelectedFile.value = null;
  if (fileInput.value) {
    fileInput.value.value = null;
  }
  selectedFileName.value = '';
};

const uploadFile = async () => {
  if (!hasSelectedFile.value) {
    useAlert(t('PROPERTIES.IMPORT.FILE_REQUIRED'));
    return;
  }

  isImporting.value = true;
  try {
    await emit('import', hasSelectedFile.value);
    // Reset después de upload exitoso
    handleRemoveFile();
  } finally {
    isImporting.value = false;
  }
};

defineExpose({ dialogRef });
</script>

<template>
  <Dialog
    ref="dialogRef"
    :title="t('PROPERTIES.IMPORT.TITLE')"
    :confirm-button-label="t('PROPERTIES.IMPORT.BUTTON')"
    :is-loading="isImporting"
    :disable-confirm-button="!hasSelectedFile || isImporting"
    @confirm="uploadFile"
  >
    <template #description>
      <p class="mb-0 text-sm text-n-slate-11">
        {{ t('PROPERTIES.IMPORT.DESCRIPTION') }}
      </p>
    </template>

    <div class="flex flex-col gap-2">
      <div class="flex items-center gap-2">
        <label class="text-sm text-n-slate-12 whitespace-nowrap">
          {{ t('PROPERTIES.IMPORT.LABEL') }}
        </label>
        <div class="flex items-center justify-between w-full gap-2">
          <span v-if="hasSelectedFile" class="text-sm text-n-slate-12">
            {{ selectedFileName }}
          </span>
          <Button
            v-if="!hasSelectedFile"
            :label="t('PROPERTIES.IMPORT.CHOOSE_FILE')"
            icon="i-lucide-upload"
            color="slate"
            variant="ghost"
            size="sm"
            class="!w-fit"
            @click="handleFileClick"
          />
          <div v-else class="flex items-center gap-1">
            <Button
              :label="t('PROPERTIES.IMPORT.CHANGE')"
              color="slate"
              variant="ghost"
              size="sm"
              @click="handleFileClick"
            />
            <div class="w-px h-3 bg-n-strong" />
            <Button
              icon="i-lucide-trash"
              color="slate"
              variant="ghost"
              size="sm"
              @click="handleRemoveFile"
            />
          </div>
        </div>
      </div>
    </div>
    <input
      ref="fileInput"
      type="file"
      accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,.xlsx"
      class="hidden"
      @change="handleFileChange"
    />
  </Dialog>
</template>
