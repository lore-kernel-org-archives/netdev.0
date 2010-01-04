From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.33-rc1] pcnet_cs: add cis of KTI PE520
 pcmcia network card
Date: Sun, 03 Jan 2010 21:42:06 -0800 (PST)
Message-ID: <20100103.214206.144451288.davem@davemloft.net>
References: <20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<33215930.831261555546455.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51815
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751230Ab0ADFmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:42:02 -0500
In-Reply-To: <33215930.831261555546455.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Wed, 23 Dec 2009 17:05:46 +0900 (JST)

> The licence of GLOBETROTTER.cis is unclear,
> I will drop this.

You need to update your patch.

The GLOBETROTTER.cis file was removed, but you retained
the MODULE_FIRMWARE() line referencing it.  Please remove
that too.

Thanks.
