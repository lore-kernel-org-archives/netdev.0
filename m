From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] unix: convert printks to pr_<level>
Date: Fri, 06 Dec 2013 16:36:13 -0500 (EST)
Message-ID: <20131206.163613.1075839481647624361.davem@davemloft.net>
References: <52A16A19.60001@huawei.com>
	<52A1A0F8.9080506@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ebiederm@xmission.com, gaofeng@cn.fujitsu.com,
	jacob.e.keller@intel.com, netdev@vger.kernel.org,
	dborkman@redhat.com
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758136Ab3LFVgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:36:14 -0500
In-Reply-To: <52A1A0F8.9080506@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 6 Dec 2013 18:03:36 +0800

> use pr_<level> instead of printk(LEVEL)
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
