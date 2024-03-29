module GITWizard
  module Controller
    extend ActiveSupport::Concern

    included do
      class_attribute :wizard_class
      before_action :load_wizard, :load_current_step, only: %i[show update]
      before_action :process_magic_link_token, :process_skip_verification, only: %i[show]
      before_action :display_magic_link_token_error, only: %i[show]
    end

    def index
      query_params = request.query_parameters
      redirect_to(step_path(wizard_class.first_key, query_params), status: :moved_permanently)
    end

    def show
      # current_step loaded via before_action
    end

    def update
      @current_step.assign_attributes step_params

      if @current_step.save
        redirect_to next_step_path

        # Needs to occur after redirect because it purges data after submission
        @wizard.complete!
      else
        render :show, status: :unprocessable_entity
      end
    end

    def completed
      # current_step is loaded via before_action
    end

    def resend_verification
      request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(identity_data)
      GetIntoTeachingApiClient::CandidatesApi.new.create_candidate_access_token(request)
      redirect_to authenticate_path(verification_resent: true)
    rescue GetIntoTeachingApiClient::ApiError => e
      redirect_to(first_step_path) && return if e.code == 400

      raise
    end

  private

    def process_skip_verification
      return unless request.query_parameters[:skip_verification]

      request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(identity_data)
      @wizard.process_unverified_request(request)
      wizard_store["authenticate"] = false
      redirect_to(step_after_authenticate_path)
    rescue GetIntoTeachingApiClient::ApiError => e
      redirect_to(first_step_path) && return if e.code == 404

      raise
    end

    def process_magic_link_token
      token = request.query_parameters[:magic_link_token]
      return if token.blank?

      @wizard.process_magic_link_token(token)
      redirect_to(step_after_authenticate_path)
    rescue GetIntoTeachingApiClient::ApiError => e
      handle_magic_link_token_error(e) && return if e.code == 401

      raise
    end

    def handle_magic_link_token_error(error)
      response = JSON.parse(error.response_body)
      redirect_to(first_step_path(magic_link_token_error: response["status"]))
    end

    def display_magic_link_token_error
      magic_link_token_error = params[:magic_link_token_error]
      return if magic_link_token_error.blank?

      key = "activemodel.errors.magic_link_token"
      message = t("#{key}.#{magic_link_token_error.underscore}", default: t("#{key}.invalid"))
      @current_step.flash_error(message)
    end

    def load_wizard
      @wizard = wizard_class.new(wizard_store, params[:id])
    rescue GITWizard::UnknownStep
      raise_not_found
    end

    def load_current_step
      @current_step = @wizard.find_current_step
    end

    def next_step_path
      if (next_key = @wizard.next_key)
        step_path next_key
      elsif (exit_step = @wizard.first_exit_step)
        step_path exit_step
      elsif (invalid_step = @wizard.first_invalid_step)
        step_path invalid_step
      else # all steps valid so completed
        completed_step_path
      end
    end

    def first_step_path(opts = {})
      step_path(wizard_class.steps.first.key, opts)
    end

    def step_after_authenticate_path
      step_path(@wizard.next_key(GITWizard::Steps::Authenticate.key))
    end

    def completed_step_path
      step_path :completed
    end

    def step_params
      params.fetch(step_param_key, {}).permit @current_step.attributes.keys
    end

    def step_param_key
      @current_step.class.model_name.param_key
    end

    def authenticate_path(params = {})
      step_path :authenticate, params
    end

    def identity_data
      GITWizard::Steps::Authenticate.new(nil, wizard_store).candidate_identity_data
    end
  end
end
