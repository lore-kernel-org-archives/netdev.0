From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make sure sockets implement splice_read
Date: Fri, 15 Feb 2008 02:36:01 -0800 (PST)
Message-ID: <20080215.023601.219994317.davem@davemloft.net>
References: <200802141853.35016.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: rdenis@simphalempin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752924AbYBOKf2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 05:35:28 -0500
In-Reply-To: <200802141853.35016.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi_Denis-Courmont <rdenis@simphalempin.com>
Date: Thu, 14 Feb 2008 18:53:34 +0200

> Fixes a segmentation fault when trying to splice from a non-TCP socke=
t.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <rdenis@simphalempin.com>

Applied, thank you.
