From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 0/20][IPV6/XFRM] MIPv6 CN (part B)
Date: Sat, 29 Jul 2006 18:37:04 +0900
Message-ID: <44CB2C40.9040900@linux-ipv6.org>
References: <44CB2914.9010803@linux-ipv6.org> <44CB2A2D.4090808@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:22673 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1422706AbWG2JhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:37:07 -0400
To: davem@davemloft.net
In-Reply-To: <44CB2A2D.4090808@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is Part B patches, following this mail.

Part B is also available as mip6cn-20060716-review branch at:

git://git.skbuff.net:9419/gitroot/nakam/linux-2.6-mip6cn

This tree includes part A, then it has all patches about
"Advanced XFRM for CN".



> Please see patches about "Avanced XFRM for CN", following this mail.
> These are just for review, and it is against 2.6.17.
> 
> "Avanced XFRM for CN" tree is consists of:
> 
>  A. XFRM extension for route optimization
>  B. IPv6 extension headers:
> 	new type (2) of routing header
> 	new TLV option for destination options header: home address option
> 	new header for signaling: mobility header
> 
[snip]

>> 3. Advanced XFRM for CN
>> "Route optimization" defined MIPv6 specification
>> is designed as XFRM extension. IPv6 extension headers
>> handling is included, too.
>> This feature is required by all MIPv6 nodes(CN, MN, HA) then it can
>> be said MIPv6 platform.

Thanks,


-- 
Masahide NAKAMURA
