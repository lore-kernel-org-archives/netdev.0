From: David Miller <davem@davemloft.net>
Subject: Re: bgmac: fix a missing check for build_skb
Date: Wed, 13 Jan 2016 10:34:51 -0500 (EST)
Message-ID: <20160113.103451.307083333479914494.davem@davemloft.net>
References: <1452674087.4516.3.camel@redhat.com>
	<5696262D.3040803@huawei.com>
	<56962DAF.9040807@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangweidong1@huawei.com, pabeni@redhat.com, zajec5@gmail.com,
	hauke@hauke-m.de, joe@perches.com, peter.senna@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nbd@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56962DAF.9040807@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Felix Fietkau <nbd@openwrt.org>
Date: Wed, 13 Jan 2016 11:57:51 +0100

> Dave, why did you apply this patch so fast without any chance of
> review?

Because I wanted to clear my backlog %100 for the merge window
initial pull request.

The patch looked simple enough, I did read it carefully, and I
did unfortunately miss the logic error.
