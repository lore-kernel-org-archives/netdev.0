From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] r6040: make printks consistent with DRV_NAME
Date: Thu, 08 Jan 2009 11:01:18 -0800 (PST)
Message-ID: <20090108.110118.211778968.davem@davemloft.net>
References: <200901071740.31046.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757525AbZAHTBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:01:16 -0500
In-Reply-To: <200901071740.31046.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 7 Jan 2009 17:40:30 +0100

> r6040: make printks consistent with DRV_NAME
> 
> This patch fixes some printks which were not prefixed
> with DRV_NAME, useful when having multiple cards/drivers
> on the system.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
