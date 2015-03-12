From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/15] net/mlx5_core: don't export static symbol
Date: Thu, 12 Mar 2015 00:04:23 -0400 (EDT)
Message-ID: <20150312.000423.2003322738364745908.davem@davemloft.net>
References: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
	<1426092997-30605-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli@mellanox.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel@iogearbox.net
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbbCLEE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:04:26 -0400
In-Reply-To: <1426092997-30605-4-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 11 Mar 2015 17:56:25 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thank you Julia.
