From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] mlx4_core: fix memory leak at
 multi_func_cleanup
Date: Mon, 06 Feb 2012 12:13:13 -0500 (EST)
Message-ID: <20120206.121313.1272368607632831388.davem@davemloft.net>
References: <4F2FFF29.2030701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033Ab2BFRNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:13:22 -0500
In-Reply-To: <4F2FFF29.2030701@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 6 Feb 2012 18:26:17 +0200

> From: Eugenia Emantayev <eugenia@mellanox.co.il>
> 
> Perform cleanup also in non-master flow.
> The VFs use communication channel as well.
> 
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>

Applied.
