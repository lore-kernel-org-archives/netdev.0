From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ethernet :mellanox :mlx5: Replace pci_pool_alloc by
 pci_pool_zalloc
Date: Wed, 30 Nov 2016 14:57:33 -0500 (EST)
Message-ID: <20161130.145733.770298826716028037.davem@davemloft.net>
References: <20161129212018.GA5419@jordon-HP-15-Notebook-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, sahu.rameshwar73@gmail.com
To: jrdr.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757955AbcK3UEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 15:04:39 -0500
In-Reply-To: <20161129212018.GA5419@jordon-HP-15-Notebook-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 30 Nov 2016 02:50:18 +0530

> In alloc_cmd_box(), pci_pool_alloc() followed by memset will be
> replaced by pci_pool_zalloc()
> 
> Signed-off-by: Souptick joarder <jrdr.linux@gmail.com>

Applied.
