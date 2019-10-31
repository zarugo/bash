#!/usr/bin/python3
import os, sys, csv, json, requests
jms = input('Type the ip of JMS:  ')
username = input('Type the username of the third party:  ')
password = input('Type the password of the third party:  ')
input_file = input('Type the name of the file (it must be in this directory):  ')
if os.path.isfile(input_file) is False:
    print('The csv file does not exists on this directory, please check that the name is correct.')
    quit()
else:
    pass

# Do the login and get the token every time

auth_url = 'http://' + jms + ':8080/janus-integration/api/ext/login'
log_headers = { 'Content-Type': 'application/json' , 'Accept': 'application/json'}
logindata = { "username": username,	"password": password }
try:
    r = requests.post(auth_url, json=logindata, headers=log_headers, timeout=10.0)
    if r.status_code == 401:
        print('The user or password are not correct. Verify that the Third Party account is set up on JMS')
        exit()
    else:
        token = (json.loads(r.text)['item']['token']['value'])
except Exception as e:
    print('Soething went wrong, the error is ' + str(e))


with open(input_file) as csvfile:
    reader = csv.DictReader(csvfile)
    title = reader.fieldnames
    for line in reader:
        csv_lines = {}
        null = None
        csv_lines["customerId"] = null
        for i in range(len(title)):
            csv_lines[title[i]] = line[title[i]]
        create_url = 'http://' + jms + ':8080/janus-integration/api/ext/customer/create'
        headers = { 'Content-Type': 'application/json' , 'Accept': 'application/json', 'Janus-TP-Authorization': token }
        data = (json.dumps(csv_lines, sort_keys=False, indent=4, separators=(',',': '), ensure_ascii=False))
        try:
            r = requests.post(create_url, headers=headers, data=data, timeout=10.0)

            #print(r.status_code)
            #print(r.headers)

        except Exception as e:
            print('Soething went wrong, the error is ' + str(e))
        print(data)

print('The upload is done, please check on JMS that the customers are there')







#os.remove("out_file.json")
