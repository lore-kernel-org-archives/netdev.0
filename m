From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 0/2] Bugfixs for hns ethernet driver
Date: Sat, 08 Jul 2017 11:05:54 +0100 (WEST)
Message-ID: <20170708.110554.1721315133073522604.davem@davemloft.net>
References: <1499307720-218834-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linyunsheng@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499307720-218834-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lin Yun Sheng <linyunsheng@huawei.com>
Date: Thu, 6 Jul 2017 10:21:58 +0800

> This patchset fix skb used after free and C45 op code issues
> in hns driver.
> 
> Patch V2:
> 	1. Remove ndev->feature checking in TX description patch.
> 	2. Add Fixes: Tag in patch description.
> 
> Patch V1:
> 	Initial Submit

Series applied, thanks.
