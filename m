From: David Miller <davem@davemloft.net>
Subject: Re: [FIX PATCH net] mlx4_en: nullify cq->vector field when closing
 completion queue
Date: Fri, 30 Dec 2011 17:16:16 -0500 (EST)
Message-ID: <20111230.171616.1116293904077742908.davem@davemloft.net>
References: <4EFC8C26.3060006@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab1L3WQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 17:16:25 -0500
In-Reply-To: <4EFC8C26.3060006@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 29 Dec 2011 17:49:58 +0200

> Caused loss of connectivity when changing ring size.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied, thanks.
