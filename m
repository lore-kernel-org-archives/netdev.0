From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH] net: macb: add fixed-link node support
Date: Tue, 20 Jun 2017 10:33:48 +0200
Message-ID: <20170620083347.usamcuycyctitmcw@pengutronix.de>
References: <20170616085536.20442-1-m.grzeschik@pengutronix.de>
 <f9b2d4f7-3751-af45-c347-5f996586b15e@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: Nicolas Ferre <nicolas.ferre@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50115 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751078AbdFTIdu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 04:33:50 -0400
Content-Disposition: inline
In-Reply-To: <f9b2d4f7-3751-af45-c347-5f996586b15e@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

On Mon, Jun 19, 2017 at 12:54:10PM +0200, Nicolas Ferre wrote:
> Le 16/06/2017 à 10:55, Michael Grzeschik a écrit :
> > In case the MACB is directly connected to a
> > non-mdio PHY/device, it should be possible to provide
> > a fixed link configuration in the DT.
> > 
> > Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> > ---

I just found a similar patch from Moritz Fischer today:

Would you prefer to take his instead?

http://www.spinics.net/lists/kernel/msg2205491.html

Thanks for the review!
Michael


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
