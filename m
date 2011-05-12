From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Thu, 12 May 2011 18:02:01 -0400 (EDT)
Message-ID: <20110512.180201.681744428234299763.davem@davemloft.net>
References: <20110512111009.GA4176@tuxmaker.boeblingen.de.ibm.com>
	<BANLkTimUq-6E1F_ns_jTvXuYoPU-sLUmqw@mail.gmail.com>
	<20110512115959.GA37368@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758736Ab1ELWCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:02:06 -0400
In-Reply-To: <20110512115959.GA37368@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Thu, 12 May 2011 13:59:59 +0200

> Since this is RX processing there is nothing queued during recovery. But
> you are right for tx csum or TSO we have to think about this. For now
> I would like to complete this patch.

Can you guys resolve this quickly so that I can apply this patch
series?
