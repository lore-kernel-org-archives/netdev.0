From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] mlx4_en: make mlx4_log_num_mgm_entry_size static
Date: Mon, 03 Jul 2017 02:41:43 -0700 (PDT)
Message-ID: <20170703.024143.1454476871860447390.davem@davemloft.net>
References: <1499060119-7063-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tariqt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, yuval.shaia@oracle.com, leon@kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753608AbdGCJlq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:41:46 -0400
In-Reply-To: <1499060119-7063-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Mon,  3 Jul 2017 01:35:19 -0400

> The variable mlx4_log_num_mgm_entry_size is only called in main.c.
> 
> CC: Joe Jin <joe.jin@oracle.com>
> CC: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied, thank you.
