From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] appletalk: convert printks to pr_<level>
Date: Fri, 14 Feb 2014 16:21:40 -0500 (EST)
Message-ID: <20140214.162140.2002526350518382167.davem@davemloft.net>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
	<1392363826-8256-4-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbaBNVVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:21:42 -0500
In-Reply-To: <1392363826-8256-4-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 14 Feb 2014 15:43:45 +0800

> Prefer pr_<level> then printk(LEVEL).
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Not applied, please sort out the pr_debug() vs. printk(KERN_DEBUG
differences pointed out to you.

Thanks.
