From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH  v2 00/13] 2.6.20 Chelsio T3 RDMA Driver
Date: Sat, 02 Dec 2006 16:24:47 -0800
Message-ID: <4572194F.8060309@osdl.org>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int> <20061202231329.GA10719@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>, rdreier@cisco.com,
	netdev@vger.kernel.org, openib-general@openib.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1424902AbWLCA2N@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061202231329.GA10719@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Steve Wise <swise@opengridcomputing.com> :
> [...]
>   
>> Version 2 changes:
>>
>> - Make code sparse endian clean
>> - Use IDRs for mapping QP and CQ IDs to structure pointers instead of arrays
>> - Clean up confusing bitfields
>> - Use random32() instead of local random function
>> - Use krefs to track endpoint reference counts
>> - Misc nits
>>
>> -----
>>
>> The following series implements the Chelsio T3 iWARP/RDMA Driver to
>> be considered for inclusion in 2.6.20.  It depends on the Chelsio T3
>> Ethernet Driver which is also under review now for 2.6.20. See:
>>     
>
> I understood that Stephen expressed some doubts regarding the inclusion
> of TOE enabled features.
>
> Was his point addressed ?
>
>   

My comments were about different hardware.
