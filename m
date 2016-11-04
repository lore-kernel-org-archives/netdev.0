From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] Mellanox 100G mlx5 fixes 2016-11-04
Date: Fri, 04 Nov 2016 15:00:24 -0400 (EDT)
Message-ID: <20161104.150024.2152794134338396213.davem@davemloft.net>
References: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, brouer@redhat.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932299AbcKDTAb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 15:00:31 -0400
In-Reply-To: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Fri,  4 Nov 2016 01:48:41 +0200

> This series contains six hot fixes of the mlx5 core and mlx5e driver.
> 
> Huy fixed an invalid pointer dereference on initialization flow for when
> the selected mlx5 load profile is out of range.
> 
> Or provided three eswitch offloads related fixes
>  - Prevent changing NS of a VF representor. 
>  - Handle matching on vlan priority for offloaded TC rules
>  - Set the actions for offloaded rules properly
> 
> On my part I here addressed the error flow related issues in
> mlx5e_open_channel reported by Jesper just this week.

Series applied, thanks.
