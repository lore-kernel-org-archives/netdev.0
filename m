From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/13] net/ipv6/ip6_fib.c: make code static
Date: Tue, 15 Aug 2006 00:11:33 -0700 (PDT)
Message-ID: <20060815.001133.94888896.davem@davemloft.net>
References: <200608150603.k7F63lgI012963@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31924
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965267AbWHOHLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:11:32 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63lgI012963@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:46 -0700

> From: Adrian Bunk <bunk@stusta.de>
> 
> Make the following needlessly global code static:
> - fib6_walker_lock
> - struct fib6_walker_list
> - fib6_walk_continue()
> - fib6_walk()
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.19
