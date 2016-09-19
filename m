From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] cxgb4: Fix return value check in cfg_queues_uld()
Date: Mon, 19 Sep 2016 01:42:49 -0400 (EDT)
Message-ID: <20160919.014249.1649892858012372635.davem@davemloft.net>
References: <1474127537-14230-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755969AbcISFmw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:42:52 -0400
In-Reply-To: <1474127537-14230-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat, 17 Sep 2016 15:52:17 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix the retrn value check which testing the wrong variable
> in cfg_queues_uld().
> 
> Fixes: 94cdb8bb993a ("cxgb4: Add support for dynamic allocation of
> resources for ULD")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
