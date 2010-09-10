From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7 v3] au1000-eth: remove volatiles, switch to I/O
 accessors
Date: Thu, 09 Sep 2010 21:37:45 -0700 (PDT)
Message-ID: <20100909.213745.191384620.davem@davemloft.net>
References: <201009082311.53406.florian@openwrt.org>
	<201009082315.14221.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752594Ab0IJEh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 00:37:28 -0400
In-Reply-To: <201009082315.14221.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 8 Sep 2010 23:15:13 +0200

> Remove all the volatile keywords where they were used, switch to using the
> proper readl/writel accessors.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
