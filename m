From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 15/15] tipc: remove old ASCII netlink API
Date: Wed, 08 Oct 2014 13:19:20 -0400 (EDT)
Message-ID: <20141008.131920.954722537334588424.davem@davemloft.net>
References: <A2BAEFC30C8FD34388F02C9B3121859D1C2EB615@eusaamb103.ericsson.se>
	<20141006.152003.1261907320590776614.davem@davemloft.net>
	<543527D6.2060607@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbaJHRTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 13:19:24 -0400
In-Reply-To: <543527D6.2060607@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Wed, 8 Oct 2014 14:02:30 +0200

> Alright. Can we log a deprecated warning when using the old API and
> eventually phase it out?

"Eventually phase it out" just means "break it later" to me, so no.
