From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 35/44] [XFRM]: Trace which secpath state is reject
 factor.
Date: Wed, 23 Aug 2006 20:41:18 -0700 (PDT)
Message-ID: <20060823.204118.85818294.davem@davemloft.net>
References: <11563453672959-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345367208-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453673786-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13210
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030261AbWHXDlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:41:15 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453673786-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:36 +0900

> For Mobile IPv6 usage, it is required to trace which secpath state is reject
> factor in order to notify it to user space (to know the address which cannot
> be used route optimized communication).
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Henrik Petander <petander@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks.
