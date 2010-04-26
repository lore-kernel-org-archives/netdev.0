From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r8169: failure to enable mwi should not be fatal
Date: Mon, 26 Apr 2010 15:37:40 -0700 (PDT)
Message-ID: <20100426.153740.116367306.davem@davemloft.net>
References: <20100426214206.GA7624@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, conikost@gmx.de, dave@thedillows.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53341
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755107Ab0DZWhg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 18:37:36 -0400
In-Reply-To: <20100426214206.GA7624@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois Romieu <romieu@fr.zoreil.com>
Date: Mon, 26 Apr 2010 23:42:06 +0200

> Few (6) network drivers enable mwi explicitly. Fewer worry about a
> failure.
>=20
> It is not a fix but it should avoid some annoyance like
> http://bugzilla.kernel.org/show_bug.cgi?id=3D15454
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Conrad Kostecki <conikost@gmx.de>

Applied.
