From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers: net: xgene-v2: Fix error return code
 in xge_mdio_config()
Date: Tue, 25 Apr 2017 13:48:36 -0400 (EDT)
Message-ID: <20170425.134836.859018406610200442.davem@davemloft.net>
References: <20170425113650.22730-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1429674AbdDYRsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:48:38 -0400
In-Reply-To: <20170425113650.22730-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 25 Apr 2017 11:36:50 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return error code -ENODEV from the no PHY found error
> handling case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thanks.
