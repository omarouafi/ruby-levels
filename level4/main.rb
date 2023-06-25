require 'json'
require 'date'

data = File.read('data.json')
parsed_data = JSON.parse(data)

workers = parsed_data['workers']
shifts = parsed_data['shifts']

payment_data = workers.map do |worker|
  shifts_for_worker = shifts.select { |shift| shift['user_id'] == worker['id'] }

  if worker['status'] == 'medic'
    shift_payment = 270
  elsif worker['status'] == 'intern'
    shift_payment = 126
  elsif worker['status'] == 'interim'
    shift_payment = 480
  else
    shift_payment = 0
  end

  total_payment = shifts_for_worker.sum do |shift|
    start_date = Date.parse(shift['start_date'])
    if start_date.saturday? || start_date.sunday?
      shift_payment * 2
    else
      shift_payment
    end
  end

  commission = total_payment * 0.05
  total_payment_with_commission = total_payment + commission

  {
    'worker_id': worker['id'],
    'worker_name': worker['first_name'],
    'total_payment': total_payment,
    'commission': commission,
    'total_payment_with_commission': total_payment_with_commission
  }
end

output_data = {
  'payments': payment_data
}

File.open('output.json', 'w') do |file|
  file.write(JSON.pretty_generate(output_data))
end
