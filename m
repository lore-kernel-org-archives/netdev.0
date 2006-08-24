From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 41/44] [XFRM]: Add sorting interface for state and
 template.
Date: Wed, 23 Aug 2006 22:48:50 -0700 (PDT)
Message-ID: <20060823.224850.52117527.davem@davemloft.net>
References: <11563453672872-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671273-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453674024-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:898
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030313AbWHXFsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 01:48:47 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453674024-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:42 +0900

> Under two transformation policies it is required to merge them.
> This is a platform to sort state for outbound and templates
> for inbound respectively.
> It will be used when Mobile IPv6 and IPsec are used at the same time.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks.
