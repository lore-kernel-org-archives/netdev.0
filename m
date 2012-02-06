From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] mlx4_core: use correct flag for unicast_promisc
Date: Mon, 06 Feb 2012 12:13:21 -0500 (EST)
Message-ID: <20120206.121321.89445568338596595.davem@davemloft.net>
References: <4F2FFF35.3050900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab2BFRN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:13:28 -0500
In-Reply-To: <4F2FFF35.3050900@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 6 Feb 2012 18:26:29 +0200

> From: Eugenia Emantayev <eugenia@mellanox.co.il>
> 
> Use MLX4_DEV_CAP_FLAG_VEP_UC_STEER for unicast_promisc_add/remove
> Unicast entries were managed in wrong data structures.
> 
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>

Applied.
