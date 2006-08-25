From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [IPV6] ROUTE: Add support for fwmask in routing
 rules.
Date: Fri, 25 Aug 2006 16:05:57 -0700 (PDT)
Message-ID: <20060825.160557.133288686.davem@davemloft.net>
References: <20060826.000937.92483566.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1969
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964801AbWHYXFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:05:52 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060826.000937.92483566.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 26 Aug 2006 00:09:37 +0900 (JST)

> [IPV6] ROUTE: Add support for fwmask in routing rules.
> 
> Add support for fwmark masks.
> A mask of 0xFFFFFFFF is used when a mark value != 0 is sent without a mask.
> 
> Based on patch for net/ipv4/fib_rules.c by Patrick McHardy <kaber@trash.net>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
