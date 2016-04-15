From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH pci] pci: Add helper function to set VPD size
Date: Fri, 15 Apr 2016 11:12:02 -0500
Message-ID: <571112D2.4010801@opengridcomputing.com>
References: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
 <00d801d1967c$68e9d100$3abd7300$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Hariprasad Shenai' <hariprasad@chelsio.com>, davem@davemloft.net,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	leedom@chelsio.com, nirranjan@chelsio.com, santosh@chelsio.com
To: bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <00d801d1967c$68e9d100$3abd7300$@opengridcomputing.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/14/2016 1:35 PM, Steve Wise wrote:
>> The fix is to add a PCI helper function to set the VPD size, so the
>> driver can expicitly set the exact size of the VPD.
>>
>> Fixes commit 104daa71b396 ("PCI: Determine actual VPD size on first access")
>>
>> Signed-off-by: Casey Leedom <leedom@chelsio.com>
>> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> Looks good!
>    
> Tested-by: Steve Wise <swise@opengridcomputing.com>
>
>

Hey Bjorn,

Will this make the next 4.6-rc?

Thanks,

Steve.
