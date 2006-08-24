From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension
 headers sorting.
Date: Wed, 23 Aug 2006 23:54:04 -0700 (PDT)
Message-ID: <20060823.235404.108743952.davem@davemloft.net>
References: <11563453682841-git-send-email-yoshfuji@linux-ipv6.org>
	<20060823.225706.03601250.davem@davemloft.net>
	<20060824.150442.44820672.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:465
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030363AbWHXGyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 02:54:06 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060824.150442.44820672.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 15:04:42 +0900 (JST)

> In article <20060823.225706.03601250.davem@davemloft.net> (at Wed, 23 Aug 2006 22:57:06 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > Are there any other Mobile-IPV6 patches necessary for the
> > kernel?
> 
> The patches cover most of MIPv6 and CN should work.
> However, for HA/MN, there are small number of patches
> to send.
> 
> We will send them, of course.
> Nakamura-san, please describe the details.

Ok, thank you.

In the mean time, I will work on porting my XFRM hashing changes
for the current net-2.6.19 tree.
