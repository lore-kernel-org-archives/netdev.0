From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/13] net/decnet/: cleanups
Date: Tue, 15 Aug 2006 00:11:19 -0700 (PDT)
Message-ID: <20060815.001119.69410310.davem@davemloft.net>
References: <200608150603.k7F63k5w012958@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29364
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965263AbWHOHLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:11:17 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63k5w012958@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:46 -0700

> From: Adrian Bunk <bunk@stusta.de>
> 
> - make the following needlessly global functions static:
>   - dn_fib.c: dn_fib_sync_down()
>   - dn_fib.c: dn_fib_sync_up()
>   - dn_rules.c: dn_fib_rule_action()
> - remove the following unneeded prototype:
>   - dn_fib.c: dn_cache_dump()
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.19
