From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] codel: use Newton method instead of sqrt()
 and divides
Date: Mon, 14 May 2012 18:33:46 -0400 (EDT)
Message-ID: <20120514.183346.1446480845531668698.davem@davemloft.net>
References: <1336859324.31653.1385.camel@edumazet-glaptop>
	<20120512.175217.1632102067268101115.davem@davemloft.net>
	<1336893803.8512.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org,
	nichols@pollere.com, van@pollere.net, codel@lists.bufferbloat.net,
	ycheng@google.com, mattmathis@google.com, therbert@google.com,
	shemminger@vyatta.com, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932305Ab2ENWfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:35:53 -0400
In-Reply-To: <1336893803.8512.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 13 May 2012 09:23:23 +0200

> Fell free to add following cleanup patch, if you like it ;)
 ...
> [PATCH net-next] codel: use u16 field instead of 31bits for rec_inv_sqrt

I do, applied :-)
