# Demo component

This component is extracted from the exiting project for the demonstration purposes.

## Intro

There are leads with labels. When some label is assigned to the lead, it initializes the lead workflow.
The domain logic of this component implements the lead label workflow.

## Lead Workflows

Each lead workflow is present with LeadWorkflow model, which contains buisness logic of the workflow.
The workflow can have a YAML config file with steps to be executed.
All steps are described in sequences so that they can have execution steps.
Each step can have one or more workflow actions to be executed.
Workflow action is a service executed in the sequence step if config params mask matches one.
Common configuration options:

### Delay:

It is usually a first parameter in the workflow step. Configures the delay time before the workflow step
should be resumed. [Use ISO 8601 Duration format](https://en.wikipedia.org/wiki/ISO_8601#Durations) to specify
the desired delay. Delay parameter can be followed by workflow actions.

```yaml
- delay: P3D
  assign_label_to_lead:
    label: 'Quoted (MIA)'
```

### Email To Customer:

Configures the email that should be sent to the customer.

```yaml
email_to_customer:
  subject: Did you receive the quotes? | %{contact_firstname}
  template_path: lead_workflows_mailer/quoted_mia
  template_name: email_1
```

### Email To Agent:

Configures the email that should be sent to the agent.

```yaml
email_to_agent:
  subject: Slow Play | %{contact_firstname } %{lead_from} - %{lead_to} | Done
  template_path: lead_workflows_mailer/not_ready
  template_name: email_6
```

### Assign label to lead:

Configures the label that should assigned to the lead.

```yaml
assign_label_to_lead:
  label: 'Quoted (MIA)'
```

### Unassign contact owner:

Unassigns the contact owner of the lead if it is not returning.

```yaml
unassign_contact_owner:
```

### Skip step with `if` condition:

The workflow step can be skiped to be planned with `if` condition.

```yaml
- if:
    - lead_returning?: false # array of conditions is parsed like AND
    - lead_was_quoted_mia?: false
    - lead_most_recent?: true
  delay: P1D
  assign_label_to_lead:
    label: 'Bonus leads'

- if:
    lead_returning?: true # hash of conditions is parsed like OR
    lead_was_quoted_mia?: true
    lead_most_recent?: false
  delay: P1D
  assign_label_to_lead:
    label: 'No Response'
```

## Lead Workflow Configurations:
- [atc.yml](config/lead_workflows/atc.yml)
- [bad_number.yml](config/lead_workflows/bad_number.yml)
- [bonus.yml](config/lead_workflows/bonus.yml)
- [charged_quote.yml](config/lead_workflows/charged_quote.yml)
- [competitor.yml](config/lead_workflows/competitor.yml)
- [domestic.yml](config/lead_workflows/domestic.yml)
- [find_flight.yml](config/lead_workflows/find_flight.yml)
- [new_quote.yml](config/lead_workflows/new_quote.yml)
- [not_ready.yml](config/lead_workflows/not_ready.yml)
- [plans_changed.yml](config/lead_workflows/plans_changed.yml)
- [quoted_mia.yml](config/lead_workflows/quoted_mia.yml)
- [recycle.yml](config/lead_workflows/recycle.yml)
- [slow_play.yml](config/lead_workflows/slow_play.yml)
