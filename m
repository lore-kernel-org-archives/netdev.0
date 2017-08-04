From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hns: Fix for __udivdi3 compiler error
Date: Fri, 04 Aug 2017 11:07:23 -0700 (PDT)
Message-ID: <20170804.110723.249014337463792010.davem@davemloft.net>
References: <1501838699-95356-1-git-send-email-linyunsheng@huawei.com>
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
In-Reply-To: <1501838699-95356-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yunsheng Lin <linyunsheng@huawei.com>
Date: Fri, 4 Aug 2017 17:24:59 +0800

> This patch fixes the __udivdi3 undefined error reported by
> test robot.
> 
> Fixes: b8c17f708831 ("net: hns: Add self-adaptive interrupt coalesce support in hns driver")
> Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>

Applied, thank you.
