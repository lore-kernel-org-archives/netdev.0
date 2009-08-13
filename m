From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc911x: includecheck fix for smc911x.h
Date: Wed, 12 Aug 2009 22:13:55 -0700 (PDT)
Message-ID: <20090812.221355.18657244.davem@davemloft.net>
References: <1249823558.2957.8.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, netdev@vger.kernel.org, dustin@sensoria.com
To: jaswinder@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37317
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751184AbZHMFNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:13:45 -0400
In-Reply-To: <1249823558.2957.8.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Sun, 09 Aug 2009 18:42:38 +0530

> 
> fix the following 'make includecheck' warning:
> 
>   drivers/net/smc911x.h: mach/dma.h is included more than once.
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Applied.
