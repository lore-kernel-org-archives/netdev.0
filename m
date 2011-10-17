From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/flow: Fix potential memory leak
Date: Mon, 17 Oct 2011 19:19:06 -0400 (EDT)
Message-ID: <20111017.191906.877362854035909797.davem@davemloft.net>
References: <CA+v9cxZ=ZYQ_nUXp-8M1Kciia2F6F0MZpq-kKGE4J-ayEGeScw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: huajun.li.lee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390Ab1JQXTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:19:09 -0400
In-Reply-To: <CA+v9cxZ=ZYQ_nUXp-8M1Kciia2F6F0MZpq-kKGE4J-ayEGeScw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huajun Li <huajun.li.lee@gmail.com>
Date: Wed, 28 Sep 2011 16:51:39 +0800

> While preparing net flow caches, once a fail may cause potential
> memory leak , fix it.
> 
> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>

Applied to net-next, thanks.
