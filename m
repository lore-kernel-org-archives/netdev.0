From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension
 headers sorting.
Date: Wed, 23 Aug 2006 22:57:06 -0700 (PDT)
Message-ID: <20060823.225706.03601250.davem@davemloft.net>
References: <11563453673854-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453681815-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453682841-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27103
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030325AbWHXF5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 01:57:04 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453682841-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:45 +0900

> Support Mobile IPv6 extension headers sorting for two transformation policies.
> Mobile IPv6 extension headers should be placed after IPsec
> transport mode, but before transport AH when outbound.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Ok, this is applied to net-2.6.19 too.

Are there any other Mobile-IPV6 patches necessary for the
kernel?
