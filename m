From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_try_coalesce returns a boolean
Date: Mon, 23 Apr 2012 23:37:17 -0400 (EDT)
Message-ID: <20120423.233717.1609276752801053480.davem@davemloft.net>
References: <CADVnQy=igJdbcG4J2HU7nEJUNM84qVcLa08h6g6MQQ8-fvgxHg@mail.gmail.com>
	<20120423.224602.594997774992725103.davem@davemloft.net>
	<1335238476.5205.122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, therbert@google.com,
	maze@google.com, ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508Ab2DXDh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 23:37:28 -0400
In-Reply-To: <1335238476.5205.122.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Apr 2012 05:34:36 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> This clarifies code intention, as suggested by David.
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
