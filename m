From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding][0/3] Synchronizing 2.4-2.6
Date: Sat, 30 Aug 2003 17:27:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F5116BD.9030601@pobox.com>
References: <200308271958.52063.shmulik.hen@intel.com> <200308302205.45924.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308302205.45924.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Shmulik Hen wrote:
> On Wednesday 27 August 2003 07:58 pm, Hen, Shmulik wrote:
> 
>>Next in store are:
>> o Stephen Hemminger's converting bonding driver /proc interface to
>>   seq_file, along with changing /proc/bond0/info to
>>   /proc/bonding/bond0
> 
> 
> Forgot to mention free_netdev().
> Is it 2.4 compatible ?


Only if you create a patch for 2.4 :)

	Jeff
