From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for/net-next 3/8] net/mlx5: Mellanox Connect-IB, core
 driver part 3/3
Date: Fri, 28 Jun 2013 21:10:41 -0700 (PDT)
Message-ID: <20130628.211041.256072234719301298.davem@davemloft.net>
References: <1372256537-21328-1-git-send-email-ogerlitz@mellanox.com>
	<1372256537-21328-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, eli@dev.mellanox.co.il,
	moshel@mellanox.com, eli@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab3F2EKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:10:42 -0400
In-Reply-To: <1372256537-21328-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 26 Jun 2013 17:22:12 +0300

> +	for (--i; i >= 0; --i) {

Please, "i--" is more canonical in for() loops.

> +	for (--i; i >= 0; --i) {

Likewise.
