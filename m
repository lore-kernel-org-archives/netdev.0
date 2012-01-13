From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Thu, 12 Jan 2012 20:06:39 -0800 (PST)
Message-ID: <20120112.200639.1308761125385796747.davem@davemloft.net>
References: <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	<1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325867504.2911.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604Ab2AMEGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 23:06:44 -0500
In-Reply-To: <1325867504.2911.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jan 2012 17:31:44 +0100

> Adds an optional Random Early Detection on each SFQ flow queue.
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Dave Taht <dave.taht@gmail.com>

I've decided to apply this, thanks everyone.
