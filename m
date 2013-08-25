From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Sun, 25 Aug 2013 02:53:36 -0400 (EDT)
Message-ID: <20130825.025336.1040542138436523971.davem@davemloft.net>
References: <1377400082.8828.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061Ab3HYGxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 02:53:40 -0400
In-Reply-To: <1377400082.8828.100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This depends upon your TCP patch, I knew this but you really should
be explicit about dependencies. :-)

And in any event I asked for a small change to the TCP patch, so...
it's not even in my queue right now.
