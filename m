From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Take care of xfrm policy when checking
 dst entries
Date: Tue, 18 Sep 2012 16:08:47 -0400 (EDT)
Message-ID: <20120918.160847.2054515542637762354.davem@davemloft.net>
References: <20120917.142504.115219640757684297.davem@davemloft.net>
	<50577F74.9040200@6wind.com>
	<20120917.155458.777649470378504320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, eric.dumazet@gmail.com, sds@tycho.nsa.gov,
	james.l.morris@oracle.com, eparis@parisplace.org, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754526Ab2IRUIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:08:49 -0400
In-Reply-To: <20120917.155458.777649470378504320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 17 Sep 2012 15:54:58 -0400 (EDT)

> I'm reconsidering putting Eric's patch into 'net' and that would
> allow me to use your v3 patches as-is.

And that's what I've done just now, thanks.
