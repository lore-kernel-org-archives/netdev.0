From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] macvtap: replace printk with netdev_err
Date: Wed, 30 Nov 2016 12:41:15 -0500 (EST)
Message-ID: <20161130.124115.474361862820383823.davem@davemloft.net>
References: <1480389992-69609-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756843AbcK3RlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:41:18 -0500
In-Reply-To: <1480389992-69609-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 29 Nov 2016 11:26:32 +0800

> This patch replaces printk() with netdev_err() for macvtap device.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
