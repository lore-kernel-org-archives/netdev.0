From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dql: Fix undefined jiffies
Date: Sun, 11 Mar 2012 20:00:13 -0700 (PDT)
Message-ID: <20120311.200013.1033411846603185356.davem@davemloft.net>
References: <alpine.DEB.2.00.1203111955270.6831@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab2CLDAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 23:00:16 -0400
In-Reply-To: <alpine.DEB.2.00.1203111955270.6831@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 11 Mar 2012 19:58:08 -0700 (PDT)

> In some configurations, jiffies may be undefined in
> lib/dynamic_queue_limits.c.  Adding include of jiffies.h to avoid
> this.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks.
