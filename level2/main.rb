require 'json'

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
  else
    shift_payment = 0
  end

  total_payment = shifts_for_worker.length * shift_payment

  {
    'worker_id': worker['id'],
    'worker_name': worker['first_name'],
    'total_payment': total_payment
  }
end

output_data = {
  'payments': payment_data
}

File.open('output.json', 'w') do |file|
  file.write(JSON.pretty_generate(output_data))
end
