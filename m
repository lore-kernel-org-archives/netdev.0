From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] au1000_eth: reorder functions
Date: Sun, 18 Jan 2009 21:56:38 -0800 (PST)
Message-ID: <20090118.215638.63392411.davem@davemloft.net>
References: <200901151647.38001.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	mano@roarinelk.homelinux.net
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752566AbZASF4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:56:37 -0500
In-Reply-To: <200901151647.38001.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Thu, 15 Jan 2009 16:47:37 +0100

> This patch reorders functions so that we can remove
> the forward declarations.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

This does not apply properly to current sources.

Please respin this patch.

Thank you.
