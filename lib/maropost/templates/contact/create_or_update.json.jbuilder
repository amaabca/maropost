json.ignore_nil!
json.auth_token Maropost.configuration.auth_token
json.contact do
  json.email data[:email]
  json.custom_field do
    json.ama_deals_discounts data[:ama_deals_discounts]
    json.ama_enews data[:ama_enews]
    json.ama_travel_especials data[:ama_travel_especials]
    json.ama_travel_weekly data[:ama_travel_weekly]
    json.ama_insurance_enews data[:ama_insurance_enews]
    json.ama_fleet_news data[:ama_fleet_news]
    json.new_member_series data[:new_member_series]
    json.personal_vehicle_reminder data[:personal_vehicle_reminder]
    json.associate_vehicle_reminder data[:associate_vehicle_reminder]
    json.business_vehicle_reminder data[:business_vehicle_reminder]
    json.ama_vr_reminder_autocall data[:ama_vr_reminder_autocall]
    json.ama_vr_reminder_email data[:ama_vr_reminder_email]
    json.ama_vr_reminder_sms data[:ama_vr_reminder_sms]
    json.cell_phone_number data[:cell_phone_number]
    json.phone_number data[:phone_number]
  end
end
