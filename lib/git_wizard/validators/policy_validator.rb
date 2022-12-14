class PolicyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?

    begin
      policy = GetIntoTeachingApiClient::PrivacyPoliciesApi.new.get_privacy_policy(value)
    rescue GetIntoTeachingApiClient::ApiError => e
      raise unless e.code == 400
    end

    record.errors.add(attribute, :invalid_policy) unless policy
  end
end
