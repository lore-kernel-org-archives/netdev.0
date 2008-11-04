From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Tue, 04 Nov 2008 13:42:36 -0800 (PST)
Message-ID: <20081104.134236.115613394.davem@davemloft.net>
References: <1225809909.10206.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38881
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754283AbYKDVnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 16:43:03 -0500
In-Reply-To: <1225809909.10206.90.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Tue, 04 Nov 2008 15:45:09 +0100

> I just bought the Sun x8 Express Quad Gigabit Ethernet Adapter you
> recommended to me.  It seem to work with the NIU driver (I can ping
> through the box), but I get a kernel warning when spamming it with
> pktgen...
> 
> Where do I go from here?
> And what do you want me to try?

Looks like the transmitter is wedged.

Using current sources I assume?
