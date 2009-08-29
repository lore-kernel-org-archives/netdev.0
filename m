From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix test of bearer_priority range in
 tipc_register_media()
Date: Sat, 29 Aug 2009 00:21:24 -0700 (PDT)
Message-ID: <20090829.002124.79608902.davem@davemloft.net>
References: <4A967603.8070707@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: per.liden@ericsson.com, tipc-discussion@lists.sourceforge.net,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751446AbZH2HVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:21:10 -0400
In-Reply-To: <4A967603.8070707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 27 Aug 2009 14:03:15 +0200

> For the bearer_priority to be less than TIPC_MIN_LINK_PRI and greater than
> TIPC_MAX_LINK_PRI is logically impossible.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied to net-next-2.6, thanks.
