From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/44] [XFRM]: Restrict authentication algorithm only
 when inbound transformation protocol is IPsec.
Date: Wed, 23 Aug 2006 18:01:12 -0700 (PDT)
Message-ID: <20060823.180112.63997527.davem@davemloft.net>
References: <1156345365264-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365312-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453652646-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10906
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751131AbWHXBBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:01:10 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453652646-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:10 +0900

> For Mobile IPv6 usage, routing header or destination options header is used and
> it doesn't require this comparison. It is checked only for IPsec template.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Looks good, applied to net-2.6.19

Thanks a lot.
