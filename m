From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/5] sfc: Implement message level control
Date: Thu, 24 Jun 2010 14:33:32 -0700 (PDT)
Message-ID: <20100624.143332.179939286.davem@davemloft.net>
References: <1277328607.2101.9.camel@achroite.uk.solarflarecom.com>
	<20100623.182920.28799851.davem@davemloft.net>
	<1277349138.26161.144.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43998
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753442Ab0FXVdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 17:33:20 -0400
In-Reply-To: <1277349138.26161.144.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 24 Jun 2010 04:12:18 +0100

> I'm hoping you're going to apply
> <http://patchwork.ozlabs.org/patch/56308> first.

I'm hoping that you will always tell me about such dependencies
in the future.

I always work my queue out of order.  If I'm heavily backlogged like
I am now, I'll sometimes apply much "simpler" to review patch
sets before more difficult ones, even if the "difficult" ones are
older.

Never assume anything, always state explicitly what tree something
is for and whether dependencies exist for things as-yet not applied.

Your style of assuming things makes life real difficult for me.
