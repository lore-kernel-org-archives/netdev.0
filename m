From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: forcedeth: Reside in 100Mbit Kconfig but also supports 1000Mbit cards
Date: Sun, 27 May 2007 01:07:50 +0200
Message-ID: <20070526230750.GA9566@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([62.75.240.18]:45035 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbXEZXwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2007 19:52:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I just needed some to t=C6=A3me to find out that the forcedeth driver I
need for my dual-port 1000Mbit card on a asus M2N-SLI deluce mainboard
resides in the 100Mbit category.

Is there a special reason for example 10/100Mbit only cards that work
with forcedeth? If all cards are 1000Mbit I would just move the
Kconfig entry over.

What would be the best way to deal with this if there are some
10/100Mbit cards which use the same driver as 1000Mbit cards?

regards
Stefan Schmidt
