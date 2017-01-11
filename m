From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/10] Mellanox mlx5 fixes and cleanups 2017-01-10
Date: Tue, 10 Jan 2017 21:35:36 -0500 (EST)
Message-ID: <20170110.213536.874833215273637134.davem@davemloft.net>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753890AbdAKCfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:35:37 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue, 10 Jan 2017 22:33:29 +0200

> This series includes some mlx5e general cleanups from Daniel, Gil, Hadar
> and myself.
> Also it includes some critical mlx5e TC offloads fixes from Or Gerlitz.

Series applied, thanks.

> For -stable:
>  - net/mlx5e: Remove WARN_ONCE from adaptive moderation code
> 
>    Although this fix doesn't affect any functionality, I thought it is
>    better to clean this -WARN_ONCE- up for -stable in case someone hits
>    such corner case.

Queued up for -stable, thanks.
