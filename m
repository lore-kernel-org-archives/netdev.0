From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: fix build errors if ipv6 is disabled
Date: Wed, 09 Oct 2013 13:23:26 -0400 (EDT)
Message-ID: <20131009.132326.123401461853196833.davem@davemloft.net>
References: <1381295165.4971.7.camel@edumazet-glaptop.roam.corp.google.com>
	<1381313148.4971.13.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab3JIRX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:23:28 -0400
In-Reply-To: <1381313148.4971.13.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Oct 2013 03:05:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> CONFIG_IPV6=n is still a valid choice ;)
> 
> It appears we can remove dead code.
> 
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: add the missing right parenthesis in ping_bind()

Applied, thanks.
