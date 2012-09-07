From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rt_cache_flush() cleanup
Date: Fri, 07 Sep 2012 17:23:59 -0400 (EDT)
Message-ID: <20120907.172359.1474813517613646426.davem@davemloft.net>
References: <1347049631.1234.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757435Ab2IGVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 17:24:05 -0400
In-Reply-To: <1347049631.1234.35.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Sep 2012 22:27:11 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We dont use jhash anymore since route cache removal,
> so we can get rid of get_random_bytes() calls for rt_genid
> changes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
