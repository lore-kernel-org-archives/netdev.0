From: David Miller <davem@davemloft.net>
Subject: Re: AIM9 regression
Date: Tue, 23 Sep 2008 20:11:32 -0700 (PDT)
Message-ID: <20080923.201132.247222254.davem@davemloft.net>
References: <20080923133616.7d51c953@extreme>
	<48D95447.2010701@linux-foundation.org>
	<48D995E8.1090802@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, shemminger@vyatta.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751128AbYIXDLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 23:11:44 -0400
In-Reply-To: <48D995E8.1090802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 23 Sep 2008 21:20:40 -0400

> Christoph Lameter wrote:
> > Stephen Hemminger wrote:
> > 
> >> Hardware configuration please?
> > Dual Processor 4 core 8G, Xeon X5460  @ 3.16GHz, 667Mhz memory.
> 
> Network hardware configuration?
> 
> Or is the TCP test over loopback?

I'm pretty sure it's over loopback :-)
