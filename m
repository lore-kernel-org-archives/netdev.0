From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] ipv6: ip6_route.h cleanup.
Date: Wed, 13 Aug 2008 02:36:50 -0700 (PDT)
Message-ID: <20080813.023650.160487148.davem@davemloft.net>
References: <eb3ff54b0808102308w7eff9441pab4aae449136417e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751767AbYHMJgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:36:49 -0400
In-Reply-To: <eb3ff54b0808102308w7eff9441pab4aae449136417e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Mon, 11 Aug 2008 09:08:46 +0300

>   This patch removes ip6_prohibit_entry and ip6_blk_hole_entry declarations from
>   include/net/ip6_route.h as they are unused.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.

But please write your subject lines better in the future.

I had to edit the second one to be more informative otherwise we'd
have two commits in a row that both say "ipv6: ip6_route.h cleanup"
which is not very useful for someone scanning the commit logs.
