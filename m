From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 18:20:07 -0500
Message-ID: <48A0C927.8020501@opengridcomputing.com>
References: <adavdy9zc2k.fsf@cisco.com>	<20080809.224725.130946315.davem@davemloft.net>	<adabpzzzg81.fsf@cisco.com> <20080811.140918.213422266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, jgarzik@pobox.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080811.140918.213422266.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Mon, 11 Aug 2008 09:09:02 -0700
>
>   
>>  > We turn it off.  If I want to shape or filter one of these iSCSI
>>  > connections can we turn it off?
>>
>> That seems like a reasonable idea to me -- the standard thing to do when
>> a NIC offload conflicts with something else is to turn off the offload
>> and fall back to software.
>>     
>
> But as Herbert says, we can make LRO such that turning it off
> isn't necessary.
>
> Can we shape the iSCSI offload traffic without turning it off?
>   

With Chelsio's product you can do this.  Maybe Divy can provide details?



