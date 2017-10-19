# Maropost [![Build Status](https://travis-ci.org/amaabca/maropost.svg)](https://travis-ci.org/amaabca/maropost)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/maropost`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'maropost'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maropost

## Usage

To find a contact in Maropost:
``` ruby
Maropost::Api.find('email@example.com')
```

To create or update a contact in Maropost:
```ruby
  Maropost::Api.update_subscriptions(
    Maropost::Contact.new(
      email: email,
      do_not_contact: false, # or possibly true to opt in to the DoNotMailList
      ama_rewards: ama_rewards,
      ama_membership: ama_membership,
      ama_insurance: ama_insurance,
      ama_travel: ama_travel,
      ama_new_member_series: ama_new_member_series,
      ama_fleet_safety: ama_fleet_safety,
      ovrr_personal: personal_vehicle_reminder,
      ovrr_business: business_vehicle_reminder,
      ovrr_associate: associate_vehicle_reminder,
      ama_vr_reminder: ama_vr_reminder,
      ama_vr_reminder_email: ama_vr_reminder_email,
      ama_vr_reminder_sms: ama_vr_reminder_sms,
      ama_vr_reminder_autocall: ama_vr_reminder_autocall,
      cell_phone_number: cell_phone_number,
      phone: phone_number
    )
  )
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amaabca/maropost.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
