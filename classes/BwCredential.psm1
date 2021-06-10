class BwCredential {
    [string]$Collection
    [string]$Name
    [string]$Username
    [string]$Password
    [string]$Notes
    [hashtable]$PolicyExemptions
    [hashtable]$PolicyResults
    [Object[]]$Fields 

    BwCredential(){}

    BwCredential(
        [string]$Collection,
        [string]$Name,
        [string]$Username,
        [string]$Password
    )
    {
        $this.Collection = $Collection
        $this.Name = $Name
        $this.Username = $Username
        $this.Password = $Password
    }

    BwCredential(
        [string]$Collection,
        [string]$Name,
        [string]$Username,
        [string]$Password,
        [string]$Notes,
        [Object[]]$Fields
    )
    {
        $this.Collection = $Collection
        $this.Name = $Name
        $this.Username = $Username
        $this.Password = $Password
        $this.Notes = $Notes
        $this.Fields = $Fields
        $this.PolicyExemptions = @{}
        $this.PolicyResults = @{}
        #Initialize policy exemption dictionary
        foreach($field in $this.Fields){
            if($field.name -eq "PolicyExemption"){
                $policy = $field.value.split("=")
                $this.PolicyExemptions.Add($policy[0],$policy[1])
            }
        }
    }
}