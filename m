From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nfp: fix error return code in nfp_net_netdev_open()
Date: Fri, 16 Sep 2016 04:27:25 -0400 (EDT)
Message-ID: <20160916.042725.2082784130004932416.davem@davemloft.net>
References: <1473911107-8427-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, rolf.neugebauer@netronome.com,
        dinan.gunawardena@netronome.com, simon.horman@netronome.com,
        weiyongjun1@huawei.com, oss-drivers@netronome.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbcIPI13 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 04:27:29 -0400
In-Reply-To: <1473911107-8427-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 15 Sep 2016 03:45:07 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Fixes: 73725d9dfd99 ("nfp: allocate ring SW structs dynamically")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
