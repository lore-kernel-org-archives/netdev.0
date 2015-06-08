From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx5_core: Fix static checker warnings
 around system guid query flow
Date: Sun, 07 Jun 2015 20:11:29 -0700 (PDT)
Message-ID: <20150607.201129.1205716654451743322.davem@davemloft.net>
References: <1433681063-7472-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, majd@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbbFHDSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 23:18:09 -0400
In-Reply-To: <1433681063-7472-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  7 Jun 2015 15:44:23 +0300

> From: Majd Dibbiny <majd@mellanox.com>
> 
> Fix static checker warnings in the flow of system guid query.
> 
> Fixes: 707c4602cda6 ('net/mlx5_core: Add new query HCA vport commands')
> Signed-off-by: Majd Dibbiny <majd@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
