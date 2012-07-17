From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Tue, 17 Jul 2012 11:03:14 -0700 (PDT)
Message-ID: <20120717.110314.1984735460095688066.davem@davemloft.net>
References: <20120717.061418.1893307699868826531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab2GQSDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:03:17 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id AF76C5839B1
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 11:03:18 -0700 (PDT)
In-Reply-To: <20120717.061418.1893307699868826531.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 17 Jul 2012 06:14:18 -0700 (PDT)

> These patches implement the final mechanism necessary to really allow
> us to go without the route cache in ipv4.

Ok I pushed this out to net-next with the v2 of patch #5 and the merge
commit message adjusted to suit.

I think the routing cache will die in net-next for real some time
later this week.

I'll start respinning those patches.
