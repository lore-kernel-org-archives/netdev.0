From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/44] [XFRM] STATE: Introduce care-of address.
Date: Wed, 23 Aug 2006 18:19:12 -0700 (PDT)
Message-ID: <20060823.181912.17865134.davem@davemloft.net>
References: <1156345366288-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345366857-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663761-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org,
	takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9157
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965321AbWHXBTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:19:10 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453663761-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:15 +0900

> Care-of address is carried by state as a transformation option like IPsec
> encryption/authentication algorithm.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
