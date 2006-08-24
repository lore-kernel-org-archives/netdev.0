From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/44] [XFRM]: Expand XFRM_MAX_DEPTH for route
 optimization.
Date: Wed, 23 Aug 2006 17:52:24 -0700 (PDT)
Message-ID: <20060823.175224.89037363.davem@davemloft.net>
References: <11563453653169-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365325-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453653851-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54494
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965268AbWHXAwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:52:23 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453653851-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:05 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> XFRM_MAX_DEPTH is a limit of transformation states to be applied to the same
> flow. Two more extension headers are used by Mobile IPv6 transformation.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19

Thanks.
