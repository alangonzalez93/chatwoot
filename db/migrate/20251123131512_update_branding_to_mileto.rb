class UpdateBrandingToMileto < ActiveRecord::Migration[7.0]
  def up
    # Update INSTALLATION_NAME to Mileto
    config = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_NAME')
    config.value = 'Mileto'
    config.locked = true
    config.save!

    # Update BRAND_NAME to Mileto
    config = InstallationConfig.find_or_initialize_by(name: 'BRAND_NAME')
    config.value = 'Mileto'
    config.locked = true
    config.save!

    # Clear global config cache to apply changes immediately
    GlobalConfig.clear_cache
  end

  def down
    # Revert to Chatwoot if needed
    config = InstallationConfig.find_by(name: 'INSTALLATION_NAME')
    config&.update!(value: 'Chatwoot')

    config = InstallationConfig.find_by(name: 'BRAND_NAME')
    config&.update!(value: 'Chatwoot')

    GlobalConfig.clear_cache
  end
end
