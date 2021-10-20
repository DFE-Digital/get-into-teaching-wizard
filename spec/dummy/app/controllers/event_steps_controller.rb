class EventStepsController < ApplicationController
  include DFEWizard::Controller
  self.wizard_class = Events::Wizard

  def step_path(step = params[:id], urlparams = {})
    event_step_path params[:event_id], step, urlparams
  end
  helper_method :step_path

  def wizard_store
    ::DFEWizard::Store.new({}, {})
  end
end
