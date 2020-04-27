control 'cis-azure-foundations-9.2' do
  title 'Ensure that RDP access is restricted from the internet'
  desc  'The potential security problem with using RDP over the Internet is that
        attackers can use various brute force techniques to gain access to Azure
        Virtual Machines. Once the attackers gain access, they can use a virtual
        machine as a launch point for compromising other machines on an Azure
        Virtual Network or even attack networked devices outside of Azure.'
  desc 'rationale', 'The potential security problem with using RDP over the Internet is that
        attackers can use various brute force techniques to gain access to Azure Virtual
        Machines. Once the attackers gain access, they can use a virtual machine as a launch
        point for compromising other machines on an Azure Virtual Network or even attack
        networked devices outside of Azure.'
  desc 'check', "Set NSGs to have no security rules Run the following to check that no NGS
       have security rules az network nsg list --query [*].[name,securityRules]"
  desc 'fix', "Set 'AuditState' to 'Enabled' Disable direct RDP access to your Azure
       Virtual Machines from the Internet. After direct RDP access from the Internet is
       disabled, you have other options you can use to access these virtual machines for
      remote management: Point-to-site VPN, Site-to-site VPM, and ExpressRoute."

  impact 0.5
  tag 'severity': 'medium'
  tag 'cis_level': 1
  tag 'cis_rid': 9.2
  tag 'csc_control': ['6.6', '14.6', '6.0']
  tag 'nist': %w{AC-3 AU-4 Rev_4}

  azurerm_resource_groups.names.each do |rg_name|
    azurerm_storage_accounts(resource_group: rg_name).names.each do |sa_name|
      describe azurerm_network_security_group(resource_group: rg_name, name: sa_name) do
        it { should allow_rdp_from_internet }
      end
    end
  end
end
