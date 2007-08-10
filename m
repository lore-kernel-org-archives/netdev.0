From: David Miller <davem@davemloft.net>
Subject: Re: [patch 16/28] drivers/net/irda/irda-usb.c: mostly kmalloc +
 memset conversion to k[cz]alloc
Date: Fri, 10 Aug 2007 15:25:53 -0700 (PDT)
Message-ID: <20070810.152553.39328135.davem@davemloft.net>
References: <200708102112.l7ALC0EM009421@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, m.kozlowski@tuxland.pl, samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933287AbXHJWZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:25:53 -0400
In-Reply-To: <200708102112.l7ALC0EM009421@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:00 -0700

> From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/irda/irda-usb.c | 59694 -> 59541 (-153 bytes)
>  drivers/net/irda/irda-usb.o | 170588 -> 169256 (-1332 bytes)
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6, thanks!
