#
# Cookbook:: powershell_variables_example
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.


powershell_script 'write-file' do
    code <<-EOH
    
    # Set Vars with attributes
    $SubscriptionId = '#{node['SubscriptionId']}'
    $RG = '#{node['RG']}'
    $DF = '#{node['DF']}'

    # Use vars... in this case, just writing them to a file
    $stream = [System.IO.StreamWriter] "C:/powershell-test.txt"
    $stream.WriteLine("SubscriptionId = $SubscriptionId")
    $stream.WriteLine("RG = $RG")
    $stream.WriteLine("DF = $DF")
    $stream.close()
    EOH
    
  end