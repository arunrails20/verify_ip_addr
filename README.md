### 1. Solution Approach
1 In post request collect all the IPs in $all_events array variable. In the format of
 ```[{ app_sha: sample_sha, ips: [smaple_ips] }]``` app_sha is unique means if ```app_sha``` is already exists in the ```$all_events```,then update the values or else create new pair.

2. In get request will find the ```app_sha256``` from ```$all_events``` array and get all ips associated with the requested app_sha256.

3. Once collect all the ips, will do unique and sort of all ips.

4. loop through the unique_sorted ips and get the good ips. Logic will be collect good ips by checking consecutive numbers      with increment by 1, rest all are bad ips

5. Since client is generating good IPs in incremental order.

### 2. Tech stack and source code

Language: Ruby 2.5.1.
Framework: Rails 5.2.3
UnitTest: Rspec 3.8

## 3. App setup and start the server
1. Unzip the app and go to the app root folder

2. Install RVM from https://rvm.io/rvm/install

3. Install Ruby version 2.5.1

   ```$ rvm install ruby-2.5.1```
   
4. Install Rails Framework
  ```$ gem install rails -v 5.2.3```
  
5 Do install app dependency gems
  ```$ bundle install```
  
6. Start the server, by default server listen to the port 3000
  ```$ rails s```
