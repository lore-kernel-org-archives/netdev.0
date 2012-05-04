From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: factorize code (qdisc_drop())
Date: Fri, 04 May 2012 11:51:03 -0400 (EDT)
Message-ID: <20120504.115103.2149022029392225606.davem@davemloft.net>
References: <1336142241.3752.331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169Ab2EDPvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 11:51:06 -0400
In-Reply-To: <1336142241.3752.331.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 May 2012 16:37:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Use qdisc_drop() helper where possible.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
