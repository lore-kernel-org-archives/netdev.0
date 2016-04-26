From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/13] net: hns: add support of debug dsaf
 device
Date: Tue, 26 Apr 2016 01:11:16 -0400 (EDT)
Message-ID: <20160426.011116.1045874009330763236.davem@davemloft.net>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	will.deacon@arm.com, catalin.marinas@arm.com, yankejian@huawei.com,
	huangdaode@hisilicon.com, salil.mehta@huawei.com,
	lipeng321@huawei.com, liguozhu@huawei.com, xieqianqian@huawei.com,
	xuwei5@hisilicon.com, linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbcDZFLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 01:11:23 -0400
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Sat, 23 Apr 2016 17:05:04 +0800

> There are two kinds of dsaf device in hns, one is for service ports,
> contains crossbar in it, can work under different mode. Another is for
> debug port, only can work under single port mode. The current code only
> declares a dsaf device for both service ports and debug ports.It is not so
> readability. This patch separates it to three platform devices to make the
> code more simple and readability.
 ...
> We take the compatibility into consideration, and it works well by using the
> old dts file(tested on d02 board).
> 
> For more details, please see individual patches.

Series applied, thanks.
