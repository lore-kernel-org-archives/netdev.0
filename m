From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/44] [XFRM] STATE: Common receive function for route
 optimization extension headers.
Date: Wed, 23 Aug 2006 18:08:37 -0700 (PDT)
Message-ID: <20060823.180837.98555441.davem@davemloft.net>
References: <1156345365312-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453652646-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365315-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59786
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751150AbWHXBIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:08:36 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345365315-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:11 +0900

> XFRM_STATE_WILDRECV flag is introduced; the last resort state is set it
> and receives packet which is not route optimized but uses such extension
> headers i.e. Mobile IPv6 signaling (binding update and acknowledgement).
> A node enabled Mobile IPv6 adds the state.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
