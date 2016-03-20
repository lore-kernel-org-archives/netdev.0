From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: Add description for cpu_bstats argument
Date: Sun, 20 Mar 2016 16:49:08 -0400 (EDT)
Message-ID: <20160320.164908.2110474977378255243.davem@davemloft.net>
References: <1458423098-3399-1-git-send-email-luisbg@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	edumazet@google.com, ast@plumgrid.com
To: luisbg@osg.samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbcCTUtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 16:49:10 -0400
In-Reply-To: <1458423098-3399-1-git-send-email-luisbg@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luis de Bethencourt <luisbg@osg.samsung.com>
Date: Sat, 19 Mar 2016 21:31:38 +0000

> Commit 22e0f8b9322c ("net: sched: make bstats per cpu and estimator RCU safe")
> added the argument cpu_bstats to functions gen_new_estimator and
> gen_replace_estimator and now the descriptions of these are missing for the
> documentation. Adding them.
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>

Applied.
