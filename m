From: David Miller <davem@davemloft.net>
Subject: Re: [patch 15/28] drivers/net/wan/hdlc_fr.c: kmalloc + memset
 conversion to kzalloc
Date: Fri, 10 Aug 2007 15:25:04 -0700 (PDT)
Message-ID: <20070810.152504.133167300.davem@davemloft.net>
References: <200708102111.l7ALBxJj009417@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, m.kozlowski@tuxland.pl, khc@pm.waw.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758789AbXHJWZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:25:04 -0400
In-Reply-To: <200708102111.l7ALBxJj009417@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:11:58 -0700

> From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/wan/hdlc_fr.c | 31260 -> 31223 (-37 bytes)
>  drivers/net/wan/hdlc_fr.o | 144872 -> 144728 (-144 bytes)
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6, thanks!
