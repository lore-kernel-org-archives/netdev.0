From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] gro: Name the GRO result enumeration type
Date: Thu, 29 Oct 2009 21:32:23 -0700 (PDT)
Message-ID: <20091029.213223.94736944.davem@davemloft.net>
References: <1256840061.2827.80.camel@achroite>
	<1256840775.2827.83.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56784
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbZJ3Eb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 00:31:59 -0400
In-Reply-To: <1256840775.2827.83.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 29 Oct 2009 18:26:15 +0000

> This clarifies which return and parameter types are GRO result codes
> and not RX result codes.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This replaces the previous patch 1/4 and avoids introducing compiler
> warnings.  The original patches 2-4 will still apply on top of it.

You can't do this Ben.

Changing this patch makes the follow-on patches not apply cleanly.

So if you respin stuff like this, you have to respin the follow-on
patches too.

I'll fix this up, but I am so irritated that I've wasted so much time
tonight already on patch submissions that were not handled with any
care at all.  And it's all at my expense.
