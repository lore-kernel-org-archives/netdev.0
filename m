From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/pcmcia/3c574_cs: fixing stats.tx_bytes
 counter
Date: Wed, 21 Apr 2010 16:28:11 -0700 (PDT)
Message-ID: <20100421.162811.112992487.davem@davemloft.net>
References: <alpine.DEB.1.10.1003312014120.9974@blala.de>
	<20100416130101.GB7877@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akurz@blala.de, netdev@vger.kernel.org
To: linux@dominikbrodowski.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754892Ab0DUX2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:28:06 -0400
In-Reply-To: <20100416130101.GB7877@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Fri, 16 Apr 2010 15:01:01 +0200

> David,
> 
> as this is more netdev-related than PCMCIA-related, could you pick it up?
> Else, I'm willing to take it upstream, but would prefer your ACK on this.

Applied to net-2.6, thanks Dominik.
