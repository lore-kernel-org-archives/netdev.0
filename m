From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] vlan support for pktgen
Date: Thu, 14 Sep 2006 15:33:02 +0200
Message-ID: <17673.23054.12731.680791@robur.slu.se>
References: <7c923b5e0609131017i4a04512rab45cff32e09527e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:54197 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1750708AbWINNdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 09:33:04 -0400
To: "Francesco Fondelli" <francesco.fondelli@gmail.com>
In-Reply-To: <7c923b5e0609131017i4a04512rab45cff32e09527e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Francesco Fondelli writes:

 > The attached patch allows pktgen to produce 802.1Q and Q-in-Q tagged frames.
 > I have used it for stress test a bridge and seems ok to me.
 > Unfortunately I have no access to net-2.6.x git tree so the diff is against
 > 2.6.17.13.
 > If you have a moment look over it, I think this feature could be useful for
 > someone else.

 Thanks a lot, code seems code seems straight forward but I'm not to 
 experienced with VLAN hacking and need find some test environment
 when I got a chance, maybe someone else has better opportunities to 
 verify.

 Cheers.
					--ro
