From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] arp: add macro to get drop_gratuitous_arp setting
Date: Thu, 10 Mar 2016 16:17:28 -0500 (EST)
Message-ID: <20160310.161728.1218918676509397480.davem@davemloft.net>
References: <1457423630-12676-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932359AbcCJVRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 16:17:30 -0500
In-Reply-To: <1457423630-12676-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue,  8 Mar 2016 07:53:50 +0000

> Add macro IN_DEV_DROP_GRATUITOUS_ARP to facilitate getting
> drop_gratuitous_arp value.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

As it's used in one location, I see zero value in this, sorry.

I'm not applying this patch.
