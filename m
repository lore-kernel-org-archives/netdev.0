From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove isa stuff from smc91x driver
Date: Wed, 03 Dec 2008 22:23:34 -0800 (PST)
Message-ID: <20081203.222334.30065692.davem@davemloft.net>
References: <20081203151919.GD5559@pengutronix.de>
	<OF69EAE3F6.7E12E2A6-ON80257514.0059AB2C-80257514.005ABFB9@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: l.fu@pengutronix.de, alan@lxorguk.ukuu.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44396
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753886AbYLDGXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 01:23:33 -0500
In-Reply-To: <OF69EAE3F6.7E12E2A6-ON80257514.0059AB2C-80257514.005ABFB9@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Wed, 3 Dec 2008 16:30:23 +0000

> SMSC LAN91C111 *does* still exist on ISA platforms (for example PC104), 
> but
> Luotao is right: the smc91x driver support for it is broken.
> 
> I have one here on an ISA board (and it took me a long time to find 
> working PC
> hardware old enough to use this!).  I'll send a patch when I can find time 
> to
> fix it, but until then I agree this broken code should be removed.
> 
> Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

Agreed, applied to net-next-2.6, thanks everyone.
