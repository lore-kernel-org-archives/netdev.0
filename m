From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hip04_eth: fix missing error handle for
 build_skb failed
Date: Wed, 13 Jan 2016 15:48:33 -0500 (EST)
Message-ID: <20160113.154833.308245535641610440.davem@davemloft.net>
References: <5695C04D.1070709@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, arnd@arndb.de, zhangfei.gao@linaro.org,
	dan.carpenter@oracle.com, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5695C04D.1070709@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weidong Wang <wangweidong1@huawei.com>
Date: Wed, 13 Jan 2016 11:11:09 +0800

> when build_skb failed, we should goto refill the buffer.
> 
> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>

Applied, thanks.
