From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/3] net/mlx4: Bug fixes for the mlx4_en driver
Date: Mon, 25 Jun 2012 16:30:23 -0700 (PDT)
Message-ID: <20120625.163023.995332613057944721.davem@davemloft.net>
References: <1340619853-29804-1-git-send-email-yevgenyp@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756781Ab2FYXaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:30:24 -0400
In-Reply-To: <1340619853-29804-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 25 Jun 2012 13:24:10 +0300

> This is a set of 3 bug fixes generated agains net tree:
> 
> ---
> Diff from V1:
> Removed atomic counter patch for rework.
> 
> Yevgeny Petrilin (3):
> 	net/mlx4_en: Set correct port parameters during device initialization
> 	net/mlx4: Use single completion vector after NOP failure
> 	net/mlx4_en: Release QP range in free_resources

All applied, thanks.
