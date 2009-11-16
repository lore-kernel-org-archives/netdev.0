From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/can: add driver for mscan family & mpc52xx_mscan
Date: Mon, 16 Nov 2009 02:21:01 -0800 (PST)
Message-ID: <20091116.022101.241160893.davem@davemloft.net>
References: <20091113.205138.168699769.davem@davemloft.net>
	<4AFFEC2C.6000106@grandegger.com>
	<20091116101205.GA30609@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca
To: w.sang@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59104
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbZKPKUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:20:45 -0500
In-Reply-To: <20091116101205.GA30609@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>
Date: Mon, 16 Nov 2009 11:12:05 +0100

>> >> Taken from socketcan-svn, fixed remaining todos, cleaned up, tested with a
>> >> phyCORE-MPC5200B-IO and a custom board.
>> >>
>> >> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
>> > 
>> > Applied.
>> 
>> Unfortunately too early. I will send my review tomorrow. Sorry for the
>> delay.
> 
> So, I'd assume that I now have to send an incremental patch instead of a V2?

Yes.
