From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 03 Dec 2003 16:11:22 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FCE5F8A.9010503@sgi.com>
References: <3F844578.40306@sgi.com>	<20031008101046.376abc3b.davem@redhat.com>	<3F8455BE.8080300@sgi.com>	<20031008183742.GA24822@wotan.suse.de>	<20031008122223.1ba5ac79.davem@redhat.com>	<20031008202248.GA15611@oldwotan.suse.de>	<3F8702FF.70500@sgi.com>	<20031010192036.GA31727@wotan.suse.de>	<3F8802E6.5030601@sgi.com>	<20031011131921.GC21763@wotan.suse.de>	<20031011105054.0e16a607.davem@redhat.com>	<3F8C290A.3010508@sgi.com>	<20031014095323.71c8b9fe.davem@redhat.com>	<3FB03A56.7000709@sgi.com>	<20031110182911.2c5a121b.davem@redhat.com>	<3FB140E2.1070007@sgi.com> <20031111122403.2d7bcf28.davem@redhat.com> <3FB153F1.8040708@sgi.com> <3FB15550.8020807@pobox.com>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, ak@suse.de, netdev@oss.sgi.com,
        jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FB15550.8020807@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

I have not seen the change for this go into 2.6 is there something else I should be
doing ?

Thanks
John

Jeff Garzik wrote:
> John Partridge wrote:
> 
>> David S. Miller wrote:
>>
>>> On Tue, 11 Nov 2003 14:04:50 -0600
>>> Why are you depending upon MCKINLEY?  Don't all ia64 cpus
>>> give traps for unaligned memory accesses?
>>
>>
>>
>> I have no evidence of a problem with Itanium1, only on Itanium2 
>> (MCKINLEY)
>> I have seen it on HP and SGI MCKINLEY
> 
> 
> 
> Ask the other David M about eepro100.c patches he wanted to send to me...
> 
>     Jeff
> 
> 
> 

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
