From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] rds: ib: add the static type to the variables
Date: Wed, 01 Mar 2017 12:51:55 -0500 (EST)
Message-ID: <20170301.125155.287193477729242606.davem@davemloft.net>
References: <1488264340-20044-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdCARwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:52:02 -0500
In-Reply-To: <1488264340-20044-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Tue, 28 Feb 2017 01:45:40 -0500

> The variables rds_ib_mr_1m_pool_size and rds_ib_mr_8k_pool_size
> are used only in the ib.c file. As such, the static type is
> added to limit them in this file.
> 
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied.
