From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r6040: implement phylib
Date: Tue, 01 Jun 2010 00:18:37 -0700 (PDT)
Message-ID: <20100601.001837.214241915.davem@davemloft.net>
References: <201005312118.58728.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42455
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801Ab0FAHS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:18:27 -0400
In-Reply-To: <201005312118.58728.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Mon, 31 May 2010 21:18:57 +0200

> This patch adds support for using phylib and adds the required mdiobus driver
> stubs. This allows for less code to be present in the driver and removes
> the PHY status specific timer which is now handled by phylib directly.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied to net-next-2.6
