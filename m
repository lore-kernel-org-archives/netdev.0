From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hisilicon: deals with the sub ctrl by
 syscon
Date: Thu, 22 Oct 2015 07:20:05 -0700 (PDT)
Message-ID: <20151022.072005.867458819587525446.davem@davemloft.net>
References: <1445421464-238140-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liguozhu@huawei.com, yisen.zhuang@huawei.com,
	huangdaode@hisilicon.com, lipeng321@huawei.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445421464-238140-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: yankejian <yankejian@huawei.com>
Date: Wed, 21 Oct 2015 17:57:44 +0800

>   the global Soc configuration is treated by syscon, and sub ctrl bus is
> Soc bus. it has to be treated by syscon.
> 
> Signed-off-by: yankejian <yankejian@huawei.com>
> Signed-off-by: lisheng <lisheng011@huawei.com>
> Signed-off-by: lipeng <lipeng321@huawei.com>

Applied, thanks.
