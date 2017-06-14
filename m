From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] macvlan: propagate the mac address change status
 for lowerdev
Date: Wed, 14 Jun 2017 14:35:03 -0400 (EDT)
Message-ID: <20170614.143503.1313402043994504723.davem@davemloft.net>
References: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fgao@ikuai8.com, vyasevic@redhat.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdFNSfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 14:35:05 -0400
In-Reply-To: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 13 Jun 2017 22:45:11 +0800

> The macvlan dev should propagate the return value of mac address change for
> lower device in the passthru mode, instead of always return 0.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thank you.
