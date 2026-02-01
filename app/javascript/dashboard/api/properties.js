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
        'Content-Type': 'multipart/form-data',
        'X-API-Key': apiKey,
      },
    });
  }
}

export default new PropertiesAPI();
