From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/44] [XFRM]: Add XFRM_MODE_xxx for future use.
Date: Wed, 23 Aug 2006 17:47:47 -0700 (PDT)
Message-ID: <20060823.174747.18307733.davem@davemloft.net>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453651533-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63460
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965267AbWHXArp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:47:45 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453651533-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:02 +0900

> Transformation mode is used as either IPsec transport or tunnel.
> It is required to add two more items, route optimization and inbound trigger
> for Mobile IPv6.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

This looks perfectly fine.

Patch applied to net-2.6.19.

