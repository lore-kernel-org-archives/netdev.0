From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add a prefetch in socket backlog
 processing
Date: Tue, 01 May 2012 09:41:07 -0400 (EDT)
Message-ID: <20120501.094107.2104854666263362273.davem@davemloft.net>
References: <1335838029.11396.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756682Ab2EANlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 09:41:13 -0400
In-Reply-To: <1335838029.11396.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 May 2012 04:07:09 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP or UDP stacks have big enough latencies that prefetching next
> pointer is worth it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
