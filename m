From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] x25: convert printks to pr_<level>
Date: Mon, 09 Dec 2013 20:24:28 -0500 (EST)
Message-ID: <20131209.202428.160565441998367426.davem@davemloft.net>
References: <529FEDBC.9030302@huawei.com>
	<52A02233.6040700@huawei.com>
	<52A1B3F1.4020203@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, joe@perches.com
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab3LJBY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:24:29 -0500
In-Reply-To: <52A1B3F1.4020203@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 6 Dec 2013 19:24:33 +0800

> use pr_<level> instead of printk(LEVEL)
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
