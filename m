From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cs89x0: includecheck fix for cs89x0.c
Date: Wed, 12 Aug 2009 21:19:37 -0700 (PDT)
Message-ID: <20090812.211937.53476937.davem@davemloft.net>
References: <1249822796.2957.4.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nelson@crynwr.com,
	akpm@linux-foundation.org, mcruse@cti-ltd.com
To: jaswinder@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752258AbZHMET1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:19:27 -0400
In-Reply-To: <1249822796.2957.4.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Sun, 09 Aug 2009 18:29:56 +0530

> fix the following 'make includecheck' warning:
> 
>   drivers/net/cs89x0.c: asm/irq.h is included more than once.
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Applied.
