From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hip04: add missing MODULE_LICENSE
Date: Mon, 02 Feb 2015 18:51:29 -0800 (PST)
Message-ID: <20150202.185129.1647037878678890112.davem@davemloft.net>
References: <4018099.9I7f6kd5jC@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhangfei.gao@linaro.org,
	dingtianhong@huawei.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbbBCCv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 21:51:29 -0500
In-Reply-To: <4018099.9I7f6kd5jC@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 30 Jan 2015 22:57:01 +0100

> The hip04 ethernet driver causes a new compile-time warning
> when built as a loadable module:
> 
> WARNING: modpost: missing MODULE_LICENSE() in drivers/net/ethernet/hisilicon/hip04_eth.o
> see include/linux/module.h for more information
> 
> This adds the license as "GPL", which matches the header of the file.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
