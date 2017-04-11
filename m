From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] devlink: fix return value check in
 devlink_dpipe_header_put()
Date: Tue, 11 Apr 2017 14:53:55 -0400 (EDT)
Message-ID: <20170411.145355.641398899342897165.davem@davemloft.net>
References: <20170410131106.27683-1-weiyj.lk@gmail.com>
        <20170411160202.17469-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, arkadis@mellanox.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752224AbdDKSx4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 14:53:56 -0400
In-Reply-To: <20170411160202.17469-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 11 Apr 2017 16:02:02 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix the return value check which testing the wrong variable
> in devlink_dpipe_header_put().
> 
> Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1 -> v2: fix  a typo in patch comment

Applied, thanks.
