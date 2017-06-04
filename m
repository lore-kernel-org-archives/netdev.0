From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/4] add support for dissection and
 matching on ip tos and ttl
Date: Sun, 04 Jun 2017 18:12:43 -0400 (EDT)
Message-ID: <20170604.181243.182859110895522887.davem@davemloft.net>
References: <1496342260-28199-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, roid@mellanox.com,
        paulb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdFDWMs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 18:12:48 -0400
In-Reply-To: <1496342260-28199-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  1 Jun 2017 21:37:36 +0300

> The 1st two patches enable matching/classifying on ip tos and ttl by 
> the flow dissector and flower. The other two patches offload matching 
> on tcp flags and ip tos in mlx5. 
> 
> The mlx5 patches touch single file/function and not interfere with
> other inflight mlx5 submissions.

Series applied, thanks.
