From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] connector: fix compilation breakage introduced recently.
Date: Sun, 17 Dec 2006 17:09:58 -0800 (PST)
Message-ID: <20061217.170958.85671867.davem@davemloft.net>
References: <20061217112946.GA15926@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: toralf.foerster@gmx.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49649
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753344AbWLRBJ7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Dec 2006 20:09:59 -0500
To: johnpol@2ka.mipt.ru
In-Reply-To: <20061217112946.GA15926@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sun, 17 Dec 2006 14:29:46 +0300

> Linus has changed work queue structure and has not tested it with
> connector compiled in, his changes break the build.
>=20
> Attached patch fixes compilation error.
>=20
> Patch is against commit 99f5e9718185f07458ae70c2282c2153a2256c91.
>=20
> Thanks to Toralf F=F6rster for pointing this out.
>=20
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Applied, thanks Evgeniy.
