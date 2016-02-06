From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: add slave device name for debug
Date: Sat, 06 Feb 2016 03:37:44 -0500 (EST)
Message-ID: <20160206.033744.369421041204151208.davem@davemloft.net>
References: <1454401975-25984-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbcBFIhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:37:47 -0500
In-Reply-To: <1454401975-25984-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue,  2 Feb 2016 08:32:55 +0000

> netdev_dbg() will add bond device name, it will be helpful if we print
> slave device name.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied.
