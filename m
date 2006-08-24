From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/44] [IPV6]: Add Kconfig to enable Mobile IPv6.
Date: Wed, 23 Aug 2006 19:14:37 -0700 (PDT)
Message-ID: <20060823.191437.02297536.davem@davemloft.net>
References: <11563453661892-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453661207-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663743-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org,
	takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030193AbWHXCOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:14:34 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453663743-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:19 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> Add Kconfig to enable Mobile IPv6.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19

Won't we also need a selection of route optimization and/or subtree
options when enabling the mobile ipv6 config option?
