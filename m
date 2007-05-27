From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: forcedeth: Reside in 100Mbit Kconfig but also supports 1000Mbit
 cards
Date: Sat, 26 May 2007 17:29:29 -0700
Message-ID: <20070526172929.755b8d98.randy.dunlap@oracle.com>
References: <20070526230750.GA9566@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: aabdulla@nvidia.com, netdev@vger.kernel.org
To: Stefan Schmidt <stefan@datenfreihafen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:24788 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbXE0AXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 20:23:45 -0400
In-Reply-To: <20070526230750.GA9566@datenfreihafen.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 May 2007 01:07:50 +0200 Stefan Schmidt wrote:

> Hello.
>=20
> I just needed some to t=C6=A3me to find out that the forcedeth driver=
 I
> need for my dual-port 1000Mbit card on a asus M2N-SLI deluce mainboar=
d
> resides in the 100Mbit category.
>=20
> Is there a special reason for example 10/100Mbit only cards that work
> with forcedeth? If all cards are 1000Mbit I would just move the
> Kconfig entry over.
>=20
> What would be the best way to deal with this if there are some
> 10/100Mbit cards which use the same driver as 1000Mbit cards?

There has been some mention of dropping the 10/100 and 1000
categories and just merging all of them together.
Makes sense to me.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
