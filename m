From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] smc911x: Add support for LAN921{5,7,8} chips from
 SMSC
Date: Sun, 12 Oct 2008 21:05:24 -0700 (PDT)
Message-ID: <20081012.210524.53451445.davem@davemloft.net>
References: <20081011.150852.73771267.davem@davemloft.net>
	<Pine.LNX.4.64.0810120058190.4965@axis700.grange>
	<87myha2qqn.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lg@denx.de, Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751306AbYJMEFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 00:05:48 -0400
In-Reply-To: <87myha2qqn.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Sun, 12 Oct 2008 09:54:08 +0200

> >>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:
> 
>  Guennadi> LAN92{5,7,8} chips from SMSC are register compatible with
>  Guennadi> LAN911{5,6,7,8} controllers, and only add support for HP
>  Guennadi> Auto-MDIX. LAN9218 doesn't have an external MII interface.
> 
>  Guennadi> Signed-off-by: Guennadi Liakhovetski <lg@denx.de>
> 
> Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied, thanks everyone.
