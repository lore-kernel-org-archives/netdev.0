From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Remove selftest TX queues empty
 condition
Date: Sun, 01 Dec 2013 20:36:29 -0500 (EST)
Message-ID: <20131201.203629.368236277338480122.davem@davemloft.net>
References: <1385900374-27479-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3LBBga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:36:30 -0500
In-Reply-To: <1385900374-27479-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun,  1 Dec 2013 14:19:34 +0200

> From: Eugenia Emantayev <eugenia@mellanox.com>
> 
> Remove waiting for TX queues to become empty during selftest.
> This check is not necessary for any purpose, and might put
> the driver into an infinite loop.
> 
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
