From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] dummy: expend mtu range for dummy device
Date: Wed, 07 Dec 2016 13:30:15 -0500 (EST)
Message-ID: <20161207.133015.706053086920093775.davem@davemloft.net>
References: <1481103693-16394-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932192AbcLGSaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:30:17 -0500
In-Reply-To: <1481103693-16394-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed,  7 Dec 2016 17:41:33 +0800

> After commit 61e84623ace3 ("net: centralize net_device min/max MTU checking"),
> the mtu range for dummy device becomes [68, 1500].
> 
> This patch expends it to [0, 65535].
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied with "extends" typo fixed, thanks.
