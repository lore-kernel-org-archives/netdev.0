From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: remove the unnecessary assignment
Date: Thu, 16 Jan 2014 17:37:46 -0800 (PST)
Message-ID: <20140116.173746.1014767500836972443.davem@davemloft.net>
References: <52D7976F.7070708@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbaAQBhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:37:46 -0500
In-Reply-To: <52D7976F.7070708@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Thu, 16 Jan 2014 16:25:19 +0800

> When go the right path, the status is 0, no need to assign it again.
> So just remove the assignment.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thank you.
