From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] net/mlx5e: Fix del vxlan port command buffer
 memset
Date: Wed, 20 Jul 2016 15:30:14 -0700 (PDT)
Message-ID: <20160720.153014.900395376534858458.davem@davemloft.net>
References: <1469050793-29235-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matt@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762AbcGTWaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 18:30:18 -0400
In-Reply-To: <1469050793-29235-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 21 Jul 2016 00:39:53 +0300

> memset the command buffers rather than the pointers to them.
> 
> Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
> 
> V2:
>  - Improved log message.

Applied.
