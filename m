From: David Miller <davem@davemloft.net>
Subject: Re: [for-next V3 00/10][pull request] Mellanox 100G mlx5 4K UAR
 support
Date: Mon, 09 Jan 2017 17:16:36 -0500 (EST)
Message-ID: <20170109.171636.1347842948110740752.davem@davemloft.net>
References: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, leonro@mellanox.com, eli@mellanox.com,
        matanb@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdAIWQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:16:38 -0500
In-Reply-To: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Mon,  9 Jan 2017 21:00:43 +0200

> Following the mlx5-odp submission, you can find here the 2nd mlx5
> submission for 4.11 as a pull-request including mlx5 4K UAR support from
> Eli Cohen (details below).  For you Doug, this pull request will provide
> you with both mlx5 odp and mlx5 4k UAR since it is based on Dave's
> net-next mlx5-odp merge commit.
> 
> v1->v2:
>   - Removed 64BIT arch dependency.
> v2->v3:
>   - Removed extra space.

Pulled into net-next, thanks.
