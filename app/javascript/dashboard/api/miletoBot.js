/* global axios */
import ApiClient from './ApiClient';

class MiletoBotAPI extends ApiClient {
  constructor() {
    super('mileto_bot', { accountScoped: true });
  }

  /**
   * Get bot status
   * @returns {Promise} Promise object with bot status { enabled: boolean }
   */
  getBotStatus() {
    return axios.get(`${this.url}/status`);
  }

  /**
   * Toggle bot status (activate/deactivate)
   * @param {boolean} enabled - true to enable, false to disable
   * @returns {Promise} Promise object with updated status
   */
  toggleBot(enabled) {
    return axios.put(`${this.url}/toggle`, { enabled });
  }
}

export default new MiletoBotAPI();
