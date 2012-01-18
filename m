From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] mlx4_en: set number of rx rings used by RSS
 using ethtool
Date: Wed, 18 Jan 2012 16:09:06 -0500 (EST)
Message-ID: <20120118.160906.2044349227642404887.davem@davemloft.net>
References: <4F1688DF.3070107@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932185Ab2ARVJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 16:09:16 -0500
In-Reply-To: <4F1688DF.3070107@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 18 Jan 2012 10:54:55 +0200

> 
> Value must be a power of 2 due to HW limitation.
> Driver supports only 'equal' mode in ethtool and can't be set by using weights.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
> Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
