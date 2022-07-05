
# Get into Teaching Wizard

 A gem containing common logic for building multi-stage forms that ultimately submit to the GiT Dyanmics CM via the [GiT API](https://github.com/DFE-Digital/get-into-teaching-api).

We currently use this gem in two projects; the [Get into Teaching website](https://github.com/DFE-Digital/get-into-teaching-app) and [Get an adviser service](https://github.com/DFE-Digital/get-teacher-training-adviser-service). It works in conjunction with the [Get into Teaching API client library](https://github.com/DFE-Digital/get-into-teaching-api-ruby-client).

## Functionality   

The wizard gem is tightly coupled to the GiT services and has the following functionality:

- Ability to 'matchback' a candidate in the CRM
- Authentication via TOTP (including a resend mechanism) and magic links
- Ability to pre-fill steps with existing candidate information from the CRM
- Skippable and exit step types for conditional flows and disqualifying sign ups

## Usage

There is a 'dummy' application in the `spec` directory that implements a basic 'events wizard'. To construct a new wizard you will need to:

- Define a number of wizard 'steps' that inherit from `dfe_wizard/step.rb`. Each step should have a number of `ActiveModel` attributes and a view to present the form.
- Subclass `dfe_wizard/base.rb` with your own wizard, declaring steps and implementing the relevant abstract methods for exchanging a TOTP for existing candidate data. You can override `complete!` to submit a payload to the CRM API.
- Mixin the `dfe_wizard/controller.rb` concern into your controller and declare  `wizard_class` and `wizard_store`. You also need to implement the `step_path` helper so the wizard knows how to redirect to the next step in your wizard.
- Set up the necessary routes in your application:

```
resources  "steps", path:  "/signup", controller:  "wizard_steps", only:  %i[index show update]  do
  collection  do
    get  :completed
    get  :resend_verification
  end
end
```
