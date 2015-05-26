From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: ipv6_select_ident() returns a __be32
Date: Mon, 25 May 2015 20:28:35 -0400 (EDT)
Message-ID: <20150525.202835.1506947999106072571.davem@davemloft.net>
References: <201505260544.3guHqjoi%fengguang.wu@intel.com>
	<1432594941.4060.198.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, kafai@fb.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbEZA2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 20:28:40 -0400
In-Reply-To: <1432594941.4060.198.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 May 2015 16:02:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ipv6_select_ident() returns a 32bit value in network order.
> 
> Fixes: 286c2349f666 ("ipv6: Clean up ipv6_select_ident() and ip6_fragment()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>

Applied.
