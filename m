From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] mlx4 drivers: version update
Date: Wed, 07 Jun 2017 15:33:33 -0400 (EDT)
Message-ID: <20170607.153333.2137691985139660875.davem@davemloft.net>
References: <1496841975-7728-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        eranbe@mellanox.com, leonro@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752118AbdFGTdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:33:36 -0400
In-Reply-To: <1496841975-7728-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Wed,  7 Jun 2017 16:26:12 +0300

> This patchset contains version updates for the MLX4 drivers:
> Core, EN, and IB.
> 
> Just like we've done in mlx5, we modify the outdated driver
> version (reported in ethtool for example).
> This better reflects the current driver state, and removes the
> redundant date string.
> We are not going to change this frequently or even use it.
> 
> I include the IB patch in this series as it has similar subject
> and content.
> It does not cause any kind of conflict with Doug's tree.
> The rdma mailing list is CCed.
> Please let me know if I need to submit this differently.

Ok, series applied.

Doug, let me know if you want to handle this differently or want
me to change something.

Thanks.
