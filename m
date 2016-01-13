From: David Miller <davem@davemloft.net>
Subject: Re: bgmac: fix a missing check for build_skb
Date: Wed, 13 Jan 2016 00:24:52 -0500 (EST)
Message-ID: <20160113.002452.2044291838263402839.davem@davemloft.net>
References: <5695BF41.2040002@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, zajec5@gmail.com, hauke@hauke-m.de,
	joe@perches.com, peter.senna@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5695BF41.2040002@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weidong Wang <wangweidong1@huawei.com>
Date: Wed, 13 Jan 2016 11:06:41 +0800

> when build_skb failed, it may occure a NULL pointer.
> So add a 'NULL check' for it.
> 
> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>

Applied, thanks.
