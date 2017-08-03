From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: hns: Add self-adaptive interrupt coalesce
 support in hns driver
Date: Thu, 03 Aug 2017 09:21:41 -0700 (PDT)
Message-ID: <20170803.092141.880053247880811606.davem@davemloft.net>
References: <1501667857-66817-1-git-send-email-linyunsheng@huawei.com>
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
In-Reply-To: <1501667857-66817-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yunsheng Lin <linyunsheng@huawei.com>
Date: Wed, 2 Aug 2017 17:57:37 +0800

> From: Lin Yun Sheng <linyunsheng@huawei.com>
> 
> When deal with low and high throughput, it is hard to achiece both
> high performance and low latency. In order to achiece that, this patch
> calculates the rx rate, and adjust the interrupt coalesce parameter
> accordingly.
> 
> Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
> Tested-by: Weiwei Deng <dengweiwei@huawei.com>

Applied.
