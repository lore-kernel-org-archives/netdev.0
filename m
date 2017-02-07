From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net-next V2 0/6] Mellanox mlx5 updates
 2017-01-31
Date: Tue, 07 Feb 2017 13:46:24 -0500 (EST)
Message-ID: <20170207.134624.600574213828419760.davem@davemloft.net>
References: <20170206233829.29716-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755262AbdBGSq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:46:27 -0500
In-Reply-To: <20170206233829.29716-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue,  7 Feb 2017 01:38:23 +0200

> This pull request includes two new mlx5 features and two small fixes for net-next,
> Details are bleow.
> 
> Please pull and let me know if there's any problem.
> 
> Sorry for the delay on addressing the comments.
> v1->v2:
> 	- Addressed the comments on the static checker fix patch
> 	- Squash cacheline patches (it is more correct they come as one).
> 	- Dropped "net/mlx5e: Calc vlan_tag_present only once on xmit" 
>           as it doesn't seem to give any added value.

Pulled, thank you.
