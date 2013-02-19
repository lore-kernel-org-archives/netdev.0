From: David Miller <davem@davemloft.net>
Subject: net being merged into net-next
Date: Mon, 18 Feb 2013 23:38:43 -0500 (EST)
Message-ID: <20130218.233843.499087968281481496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757696Ab3BSEiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 23:38:46 -0500
Received: from localhost (cpe-66-108-118-205.nyc.res.rr.com [66.108.118.205])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 7F0A4580F82
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 20:38:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm merging net into net-next, the pending fixes in there didn't make
it to Linus in time for 3.8-final.

So I'm going to cherry pick those leftovers for -stable inclusion when
I find the time.

I'm also merging net into net-next to deal with the semantic merge
conflict caused by the xfrm6_policy.c neigh release fix on the net
side.
