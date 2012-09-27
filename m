From: David Miller <davem@davemloft.net>
Subject: Re: gre: Support GRE over IPv6
Date: Thu, 27 Sep 2012 19:07:23 -0400 (EDT)
Message-ID: <20120927.190723.573272964541704268.davem@davemloft.net>
References: <20120913160105.GA29205@elgon.mountain>
	<20120926110258.GP13767@mwanda>
	<1348659560.5093.337.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, xeb@mail.ru, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab2I0XHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:07:25 -0400
In-Reply-To: <1348659560.5093.337.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Sep 2012 13:39:20 +0200

> From: Eric Dumazet <edumazet@google.com>
 ...
> [PATCH net-next] ipv6: gre: remove ip6gre_header_parse()
> 
> dev_parse_header() callers provide 8 bytes of storage,
> so it's not possible to store an IPv6 address.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Eric.
