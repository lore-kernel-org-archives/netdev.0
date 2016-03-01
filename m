From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: pktgen: use reset to set mac header
Date: Tue, 01 Mar 2016 17:47:05 -0500 (EST)
Message-ID: <20160301.174705.375908495132301390.davem@davemloft.net>
References: <1456734090-15366-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbcCAWrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:47:07 -0500
In-Reply-To: <1456734090-15366-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Mon, 29 Feb 2016 08:21:30 +0000

> Since offset is zero, it's not necessary to use set function.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
