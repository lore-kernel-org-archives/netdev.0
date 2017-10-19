From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: hns3: Add mqprio hardware offload
 support in hns3 driver
Date: Thu, 19 Oct 2017 12:45:58 +0100 (WEST)
Message-ID: <20171019.124558.2262148691294867391.davem@davemloft.net>
References: <1508223090-37907-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linyunsheng@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752728AbdJSLqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:46:16 -0400
In-Reply-To: <1508223090-37907-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yunsheng Lin <linyunsheng@huawei.com>
Date: Tue, 17 Oct 2017 14:51:30 +0800

> When using tc qdisc, dcb_ops->setup_tc is used to tell hclge_dcb
> module to do the tm related setup. Only TC_MQPRIO_MODE_CHANNEL
> offload mode is supported.
> 
> Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>

Applied.
