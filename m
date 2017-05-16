From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Remove open coded carrier check
Date: Tue, 16 May 2017 15:49:19 -0400 (EDT)
Message-ID: <20170516.154919.738527051131248074.davem@davemloft.net>
References: <20170516122056.1534-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, netdev@vger.kernel.org, leonro@mellanox.com
To: leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEPTtU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:49:20 -0400
In-Reply-To: <20170516122056.1534-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leon@kernel.org>
Date: Tue, 16 May 2017 15:20:56 +0300

> From: Leon Romanovsky <leonro@mellanox.com>
> 
> There is inline function to test if carrier present,
> so it makes open-coded solution redundant.
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

Applied.
