From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension headers
 sorting.
Date: Fri, 25 Aug 2006 09:56:28 +0900
Message-ID: <44EE4ABC.6050604@linux-ipv6.org>
References: <20060824.150442.44820672.yoshfuji@linux-ipv6.org>	<20060823.235404.108743952.davem@davemloft.net>	<44ED4FC3.9060005@linux-ipv6.org> <20060824.045850.74749237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:28570 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S932127AbWHYA4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 20:56:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060824.045850.74749237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Thu, 24 Aug 2006 16:05:39 +0900
> 
>> David Miller wrote:
>>> In the mean time, I will work on porting my XFRM hashing changes
>>> for the current net-2.6.19 tree.
>> FYI, your work will not have any conflict with the left of MIPv6 patches
>> which I will describe later since they are almost out of XFRM.
> 
> Great.
> 
> I just finished the port and pushed all of that work to net-2.6.19,
> can folks please take a look?
> 
> I tested IPSEC as best as I could with XFRM_SUB_POLICY enabled, but I
> have no way currently to test sub-policies or MIPV6 cases.

OK, I will review it and also start my XFRM test with net-2.6.19
as I've done with my tree.

Regards,

-- 
Masahide NAKAMURA
