From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: remove casting from function calls
 through ops structure
Date: Sun, 22 Dec 2013 18:04:43 -0500 (EST)
Message-ID: <20131222.180443.1670286202211553757.davem@davemloft.net>
References: <52B1687F.8080502@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab3LVXEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:04:44 -0500
In-Reply-To: <52B1687F.8080502@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 18 Dec 2013 17:18:55 +0800

> remove the unnecessary cast.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied.
