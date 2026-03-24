/* global axios */
import ApiClient from './ApiClient';

class PropertiesAPI extends ApiClient {
  constructor() {
    super('properties', { accountScoped: true });
  }

  /**
   * Get properties list with pagination
   * @param {number} page - Page number (0-indexed)
   * @param {number} size - Page size
   * @returns {Promise} Promise with properties data
   */
  getProperties(page = 0, size = 20) {
    return axios.get(`${this.url}?page=${page}&size=${size}`);
  }

  /**
   * Get property details by ID
   * @param {number} id - Property ID
   * @returns {Promise} Promise with property details
   */
  getPropertyDetails(id) {
    return axios.get(`${this.url}/${id}`);
  }

  /**
   * Search properties by text
   * @param {string} text - Search query
   * @param {number} page - Page number (0-indexed)
   * @param {number} size - Page size
   * @returns {Promise} Promise with search results
   */
  searchProperties(text, page = 0, size = 20, rentalStatus = null) {
    const apiKey = window.chatwootConfig?.miletoApiKey;

    if (!apiKey) {
      throw new Error('Mileto API key is not configured. Please contact administrator.');
    }

    const params = { text, page, size };
    if (rentalStatus) params.rentalStatus = rentalStatus;

    return axios.get('https://api.mileto.ai/api/properties/details', {
      params,
      headers: { 'x-api-key': apiKey },
    });
  }

  /**
   * Import properties from Excel file
   * @param {File} file - Excel file to upload (.xlsx)
   * @returns {Promise} Promise with import results
   */
  importProperties(file) {
    const formData = new FormData();
    formData.append('file', file);

    // Obtener API key desde variable de entorno
    const apiKey = window.chatwootConfig?.miletoApiKey;

    if (!apiKey) {
      throw new Error('Mileto API key is not configured. Please contact administrator.');
    }

    // API externa de Mileto (NO account-scoped)
    const miletoApiUrl = 'https://api.mileto.ai/api/properties/import';

    return axios.post(miletoApiUrl, formData, {
      headers: {
        'X-API-Key': apiKey,
        // NO especificar Content-Type - axios lo configura automáticamente para FormData
      },
    });
  }

  /**
   * Export receipts and settlements to Excel file
   * @param {number} month - Month number (1-12)
   * @param {number} year - Year
   * @returns {Promise} Promise with blob data (Excel file)
   */
  exportReceipts(month, year) {
    const apiKey = window.chatwootConfig?.miletoApiKey;
    const adminFirstName = window.chatwootConfig?.miletoAdminFirstName;
    const adminLastName = window.chatwootConfig?.miletoAdminLastName;

    if (!apiKey) {
      throw new Error('Mileto API key is not configured. Please contact administrator.');
    }

    return axios.get('https://api.mileto.ai/api/properties/receipts-settlements', {
      params: { month, year, adminFirstName, adminLastName },
      headers: { 'X-API-Key': apiKey },
      responseType: 'blob',
    });
  }

  /**
   * Sync tax data from external scraper service
   * @returns {Promise} Promise with sync result
   */
  syncTaxes() {
    const apiKey = window.chatwootConfig?.miletoApiKey;

    if (!apiKey) {
      throw new Error('Mileto API key is not configured. Please contact administrator.');
    }

    return axios.post('https://api.mileto.ai/api/scraper/sync/2', null, {
      headers: { 'x-api-key': apiKey },
    });
  }
  /**
   * Register annual payment for a service
   * @param {number} propertyId - Property ID
   * @param {string} serviceType - Service type (EMOS, MUNICIPAL)
   * @param {number} totalAmount - Total amount
   * @param {number} year - Year
   * @returns {Promise} Promise with result
   */
  /**
   * Update property via JSON Patch
   * @param {number} id - Property ID
   * @param {Array} patches - Array of JSON Patch operations
   * @returns {Promise} Promise with updated property
   */
  updateProperty(id, patches) {
    const apiKey = window.chatwootConfig?.miletoApiKey;

    if (!apiKey) {
      throw new Error('Mileto API key is not configured. Please contact administrator.');
    }

    return axios.patch(`https://api.mileto.ai/api/properties/${id}`, patches, {
      headers: {
        'x-api-key': apiKey,
        'Content-Type': 'application/json-patch+json',
      },
    });
  }

  registerAnnualPayment(propertyId, serviceType, totalAmount, year) {
    const apiKey = window.chatwootConfig?.miletoApiKey;

    if (!apiKey) {
      throw new Error('Mileto API key is not configured. Please contact administrator.');
    }

    return axios.post('https://api.mileto.ai/api/properties/annual-payment', {
      propertyId,
      serviceType,
      totalAmount,
      year,
    }, {
      headers: { 'x-api-key': apiKey },
    });
  }
}

export default new PropertiesAPI();
