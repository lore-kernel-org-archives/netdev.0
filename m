From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: restore flow control credits when sending fails
Date: Thu, 30 Sep 2010 17:57:47 -0700 (PDT)
Message-ID: <20100930.175747.235695558.davem@davemloft.net>
References: <1285835630-930-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com,
	eric.dumazet@gmail.com, gulshan.karmani@stericsson.com,
	linus.walleij@stericsson.com
To: kumar.sanghvi@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43990
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752564Ab0JAA51 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 20:57:27 -0400
In-Reply-To: <1285835630-930-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Date: Thu, 30 Sep 2010 14:03:50 +0530

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> This patch restores the below flow control patch submitted by R=E9mi
> Denis-Courmont, which accidentaly got lost due to Pipe controller pat=
ch
> on Phonet.
>=20
> 	commit 1a98214feef2221cd7c24b17cd688a5a9d85b2ea
> 	Author: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> 	Date:   Mon Aug 30 12:57:03 2010 +0000
>=20
> 	Phonet: restore flow control credits when sending fails
>=20
> 	Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> 	Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
> Acked-by: Linus Walleij <linus.walleij@stericsson.com>

Applied, thank you.
