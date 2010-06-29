From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cpmac: do not leak struct net_device on phy_connect
 errors
Date: Mon, 28 Jun 2010 21:20:53 -0700 (PDT)
Message-ID: <20100628.212053.179934260.davem@davemloft.net>
References: <201006211007.49039.florian@openwrt.org>
	<201006271905.26506.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751174Ab0F2EUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 00:20:40 -0400
In-Reply-To: <201006271905.26506.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 27 Jun 2010 19:05:24 +0200

> Forgot to mention that this is relevant for -stable and current net-next-2.6

I put it into net-2.6 and since you CC:'d stable it should show up there
automatically.

