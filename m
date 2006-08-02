From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/20][IPV6/XFRM] MIPv6 CN (part B)
Date: Tue, 01 Aug 2006 17:30:51 -0700 (PDT)
Message-ID: <20060801.173051.35665426.davem@davemloft.net>
References: <44CB2914.9010803@linux-ipv6.org>
	<44CB2A2D.4090808@linux-ipv6.org>
	<44CB2C40.9040900@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45193
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750772AbWHBAav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:30:51 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44CB2C40.9040900@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:37:04 +0900

> Here is Part B patches, following this mail.
> 
> Part B is also available as mip6cn-20060716-review branch at:
> 
> git://git.skbuff.net:9419/gitroot/nakam/linux-2.6-mip6cn
> 
> This tree includes part A, then it has all patches about
> "Advanced XFRM for CN".

These patches mainly deal with the specifics of ipv6
mobility processing, they look mostly fine to me and
I could not spot any obvious errors.
