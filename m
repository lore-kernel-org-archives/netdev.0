From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 29/44] [IPV6] MIP6: Add destination options header
 transformation.
Date: Wed, 23 Aug 2006 20:32:48 -0700 (PDT)
Message-ID: <20060823.203248.112983730.davem@davemloft.net>
References: <11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453674049-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453673517-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org,
	takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58538
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030251AbWHXDcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:32:45 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453673517-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:30 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> Add destination options header transformation for Mobile IPv6.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
