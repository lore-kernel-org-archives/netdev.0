From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] macvlan: convert to use IFF_NO_QUEUE
Date: Wed, 17 Feb 2016 15:19:58 -0500 (EST)
Message-ID: <20160217.151958.477975345663760428.davem@davemloft.net>
References: <1455459039-12383-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964970AbcBQUUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 15:20:09 -0500
In-Reply-To: <1455459039-12383-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Sun, 14 Feb 2016 14:10:39 +0000

> Use IFF_NO_QUEUE to indicate that a device can run without a qdisc.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
