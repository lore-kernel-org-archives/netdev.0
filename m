From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 13:39:27 -0500 (EST)
Message-ID: <20111216.133927.505152575269693232.davem@davemloft.net>
References: <alpine.DEB.2.00.1112161053030.26765@router.home>
	<1324055686.25554.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1112161128060.26765@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, igorm@etf.rs, netdev@vger.kernel.org
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab1LPSjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:39:35 -0500
In-Reply-To: <alpine.DEB.2.00.1112161128060.26765@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Fri, 16 Dec 2011 11:29:57 -0600 (CST)

> I have some latency critical processes here and I wish I could get

I hear there's FPGAs for that.... what drives me nuts about these
discussions is that custom silicon for trading platforms is all but
inevitable, and will save tons of space and power utilization to boot.

Madly trying to focus on lowering latency in a general purpose OS so
much just to compare two numbers and execute a trade is silly when in
the end it'll be implemented in a discrete circuit.

This stuff is special purpose, so let's treat it as such.

Lowering latency is a good goal, don't get me wrong, but the extreme
goals set out in these cases is for a very specific small group of
users.
