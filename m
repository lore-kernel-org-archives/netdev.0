From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] mlx4: Bug fixes and cleanups
Date: Tue, 14 Feb 2012 14:30:23 -0500 (EST)
Message-ID: <20120214.143023.281327914225614215.davem@davemloft.net>
References: <4F3A8DB5.3020703@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757110Ab2BNTac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:30:32 -0500
In-Reply-To: <4F3A8DB5.3020703@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 14 Feb 2012 18:37:09 +0200

> This is a series of fixes and cleanups for mlx4_core driver,
> Most of them related tracking of VF resources.
> The fixes solve issues caused when the VF don't close gracefully (FLR for example)

All applied to net-next, such cleanups are absolutely not appropriate
for the net tree.
