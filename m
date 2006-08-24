From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/44] [IPV6] MIP6: Add inbound interface of routing
 header type 2.
Date: Wed, 23 Aug 2006 19:16:41 -0700 (PDT)
Message-ID: <20060823.191641.106437228.davem@davemloft.net>
References: <11563453663743-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345366676-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453662840-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19629
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030198AbWHXCQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:16:38 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453662840-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:21 +0900

> Add inbound interface of routing header type 2 for Mobile IPv6.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19

Thanks.
