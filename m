From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: check the rto_min and rto_max
Date: Sat, 30 Nov 2013 16:08:47 -0500 (EST)
Message-ID: <20131130.160847.361995350346508364.davem@davemloft.net>
References: <5299BCB8.6070409@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	dingtianhong@huawei.com
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab3K3VIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 16:08:50 -0500
In-Reply-To: <5299BCB8.6070409@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wangweidong <wangweidong1@huawei.com>
Date: Sat, 30 Nov 2013 18:23:52 +0800

> rto_min should be smaller than rto_max while rto_max should be larger
> than rto_min. so just add the check.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Please fix your submission process such that your real full name
appears in the "From: " field of your patch emails, instead of
just "wangweidong", which is your username not your real full
name.

I'm not applying your patches until you correct this and submit
the patch properly, thanks.
