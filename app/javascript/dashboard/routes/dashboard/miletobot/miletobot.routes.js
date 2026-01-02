import { frontendURL } from '../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/miletobot'),
      name: 'miletobot_wrapper',
      meta: {
        permissions: ['administrator'],
      },
      component: () => import('./Wrapper.vue'),
      children: [
        {
          path: '',
          name: 'miletobot_index',
          meta: {
            permissions: ['administrator'],
          },
          component: () => import('./Index.vue'),
        },
      ],
    },
  ],
};
