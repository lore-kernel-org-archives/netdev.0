From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pcmcia/axnet_cs: includecheck fix axnet_cs.c
Date: Wed, 12 Aug 2009 21:19:42 -0700 (PDT)
Message-ID: <20090812.211942.174547139.davem@davemloft.net>
References: <1249823125.2957.6.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dahinds@users.sourceforge.net
To: jaswinder@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbZHMETc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:19:32 -0400
In-Reply-To: <1249823125.2957.6.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Sun, 09 Aug 2009 18:35:25 +0530

> 
> fix the following 'make includecheck' warning:
> 
>   drivers/net/pcmcia/axnet_cs.c: linux/etherdevice.h is included more than once.
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Applied.
