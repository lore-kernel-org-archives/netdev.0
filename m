From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hns3: make local functions static
Date: Wed, 11 Oct 2017 15:22:15 -0700 (PDT)
Message-ID: <20171011.152215.1528295657576742719.davem@davemloft.net>
References: <1507689323-183009-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        lipeng321@huawei.com, linyunsheng@huawei.com,
        colin.king@canonical.com, netdev@vger.kernel.org
To: weiyongjun1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751285AbdJKWWQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 18:22:16 -0400
In-Reply-To: <1507689323-183009-1-git-send-email-weiyongjun1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>
Date: Wed, 11 Oct 2017 02:35:23 +0000

> Fixes the following sparse warnings:
> 
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c:464:5: warning:
>  symbol 'hns3_change_all_ring_bd_num' was not declared. Should it be static?
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c:477:5: warning:
>  symbol 'hns3_set_ringparam' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
