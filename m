From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] au1000: reorder functions
Date: Thu, 22 Jan 2009 14:07:01 -0800 (PST)
Message-ID: <20090122.140701.131783335.davem@davemloft.net>
References: <200901221204.51393.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	mano@roarinelk.homelinux.net
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752148AbZAVWG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:06:59 -0500
In-Reply-To: <200901221204.51393.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Thu, 22 Jan 2009 12:04:51 +0100

> au1000: reorder functions
> 
> This patch reorders functions so that we do longer need
> forward declarations.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks Florian.
