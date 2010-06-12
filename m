From: Andi Kleen <andi@firstfloor.org>
Subject: hamachi on offer
Date: Sat, 12 Jun 2010 11:51:25 +0200
Message-ID: <20100612095125.GA16967@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36369 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab0FLJva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 05:51:30 -0400
Received: from basil.firstfloor.org (p5B3C8BD9.dip0.t-ipconnect.de [91.60.139.217])
	by one.firstfloor.org (Postfix) with ESMTP id 767701EE801C
	for <netdev@vger.kernel.org>; Sat, 12 Jun 2010 11:51:26 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I found an old hamachi (Packet Engines GNIC II) PCI GigE card while
going through old junk. 

That was one of the first Gigabit drivers in Linux (hamachi.c), but 
probably hasn't seen much use in the last years and it's unclear if the 
driver still works.

If anyone is interested in maintaining the driver I would be willing to 
ship the card for free to them. The card is still a quite respectable Gigabit
Ethernet card.

The main drawback is that it has a fiber PHY, not copper, so one would 
need a suitable fiber switch or run it loopback with another fiber card.

I believe documentation is also still available.

Please only serious offers if you want to actually work with the code.

Thanks,
-Andi
