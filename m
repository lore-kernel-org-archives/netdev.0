From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: Add MODULE_ALIAS()
Date: Sun, 26 Sep 2010 18:50:14 -0700 (PDT)
Message-ID: <20100926.185014.35044387.davem@davemloft.net>
References: <4C9BCFC5.9090808@bergerie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vincent.stehle@laposte.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757665Ab0I0Bty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:49:54 -0400
In-Reply-To: <4C9BCFC5.9090808@bergerie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent <vincent.stehle@laposte.net>
Date: Fri, 24 Sep 2010 00:08:05 +0200

> The smsc911x ethernet driver is lacking a module alias. This does
> prevent auto-loading of the driver.
> 
> The attached patch fixes this. Please apply.

Applied, thanks.
