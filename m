From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] drivers/net/r6040.c: Eliminate double sizeof
Date: Tue, 24 Jun 2008 10:54:18 +0200
Message-ID: <200806241054.19392.florian.fainelli@telecomint.eu>
References: <Pine.LNX.4.64.0806232311570.13402@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:47848 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbYFXIyu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 04:54:50 -0400
In-Reply-To: <Pine.LNX.4.64.0806232311570.13402@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julia,

Le Monday 23 June 2008 23:12:31 Julia Lawall, vous avez =E9crit=A0:
> From: Julia Lawall <julia@diku.dk>
>
> Taking sizeof the result of sizeof is quite strange and does not seem=
 to be
> what is wanted here.

Yes, definitively.

> Signed-off-by: Julia Lawall <julia@diku.dk>

Acked-by: Florian Fainelli <florian.fainelli@telecomint.eu>
--=20
Cordialement, Florian Fainelli
------------------------------
