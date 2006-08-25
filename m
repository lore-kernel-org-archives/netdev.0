From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [IPV6] ROUTE: Fix size of fib6_rule_policy.
Date: Fri, 25 Aug 2006 16:05:09 -0700 (PDT)
Message-ID: <20060825.160509.17866677.davem@davemloft.net>
References: <20060826.000919.82157954.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1201
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964795AbWHYXFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:05:04 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060826.000919.82157954.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 26 Aug 2006 00:09:19 +0900 (JST)

> [IPV6] ROUTE: Fix size of fib6_rule_policy.
> 
> It should not be RTA_MAX+1 but FRA_MAX+1.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
