From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] mlx4_core: remove buggy sched_queue masking
Date: Tue, 06 Mar 2012 15:20:17 -0500 (EST)
Message-ID: <20120306.152017.1657399350235850743.davem@davemloft.net>
References: <4F560B8A.8080508@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030950Ab2CFUUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 15:20:24 -0500
In-Reply-To: <4F560B8A.8080508@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 6 Mar 2012 15:05:14 +0200

> Fixes a bug introduced by commit fe9a2603c, where the priority bits
> in the schedule queue field were masked out.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
