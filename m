From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: hns: update DT properties according
 to Rob's comments
Date: Fri, 29 Apr 2016 13:39:49 -0400 (EDT)
Message-ID: <20160429.133949.1719521222260369497.davem@davemloft.net>
References: <1461827344-52230-1-git-send-email-Yisen.Zhuang@huawei.com>
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
Received: from shards.monkeyblade.net ([149.20.54.216]:54049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbcD2Rjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 13:39:53 -0400
In-Reply-To: <1461827344-52230-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Thu, 28 Apr 2016 15:09:00 +0800

> There are some inappropriate properties definition in hns DT. We update the definition
> according to Rob's review comments and fix some typos in binding.
> 
> For more details, please see individual patches.

Series applied, thanks.

BTW, you reposted your 10 part series for adding the dsaf-debug device, but I
already applied the series you posted for that nearly a week ago.
