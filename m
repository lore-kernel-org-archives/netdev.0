From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] ethtool fix
Date: Wed, 18 Jan 2017 14:58:44 -0500 (EST)
Message-ID: <20170118.145844.2163869071610674850.davem@davemloft.net>
References: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752093AbdART6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 14:58:46 -0500
In-Reply-To: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Tue, 17 Jan 2017 19:19:16 +0200

> This patchset from Eran contains a fix to ethtool set_channels, where the call
> to get_channels with an uninitialized parameter might result in garbage fields.
> It also contains two followup changes in our mlx4/mlx5 Eth drivers.
> 
> Series generated against net commit:
> 0faa9cb5b383 net sched actions: fix refcnt when GETing of action after bind

Looks good, series applied, thanks.
