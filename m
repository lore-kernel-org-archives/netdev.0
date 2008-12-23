From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] r6040: fix wrong logic in mdio code
Date: Mon, 22 Dec 2008 19:42:12 -0800 (PST)
Message-ID: <20081222.194212.202406779.davem@davemloft.net>
References: <200812191056.21176.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Joe.Chou@rdc.com.tw, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52542
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753234AbYLWDmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 22:42:10 -0500
In-Reply-To: <200812191056.21176.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Fri, 19 Dec 2008 10:56:20 +0100

> Those patches should be applied to -stable as well.

I've applied all 3 patches to net-next-2.6 and will
queue them up for -stable as well, thanks.
