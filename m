From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPV6] ROUTE: Fix FWMARK support.
Date: Fri, 25 Aug 2006 16:04:43 -0700 (PDT)
Message-ID: <20060825.160443.107942893.davem@davemloft.net>
References: <20060826.000854.129978441.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:433
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964795AbWHYXEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:04:38 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060826.000854.129978441.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 26 Aug 2006 00:08:54 +0900 (JST)

> [IPV6] ROUTE: Fix FWMARK support.
> 
> - Add missing nla_policy entry.
> - type of fwmark is u32, not u8.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
