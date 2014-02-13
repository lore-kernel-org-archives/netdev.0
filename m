From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] socket: replace some printk with pr_*
Date: Thu, 13 Feb 2014 18:15:22 -0500 (EST)
Message-ID: <20140213.181522.1261942643012306934.davem@davemloft.net>
References: <1392196195-6716-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbaBMXPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:15:24 -0500
In-Reply-To: <1392196195-6716-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 12 Feb 2014 17:09:55 +0800

> Prefer pr_*(...) to printk(KERN_* ...).
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied, thank you.
