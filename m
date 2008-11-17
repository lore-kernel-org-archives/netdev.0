From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice chelsio: Convert directly reference
 of netdev->priv
Date: Sun, 16 Nov 2008 23:07:08 -0800 (PST)
Message-ID: <20081116.230708.236836026.davem@davemloft.net>
References: <49211207.9030805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, divy@chelsio.com
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752245AbYKQHHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:07:08 -0500
In-Reply-To: <49211207.9030805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 17 Nov 2008 14:41:11 +0800

> Several netdev share one adapter here.
> We use netdev->ml_priv of the netdevs point to the first netdev's priv.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks.
