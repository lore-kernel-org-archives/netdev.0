From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcpv6: fix option space offsets with md5
Date: Wed, 08 Oct 2008 14:37:00 -0700 (PDT)
Message-ID: <20081008.143700.267166121.davem@davemloft.net>
References: <Pine.LNX.4.64.0810090028040.8595@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757150AbYJHVhY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 17:37:24 -0400
In-Reply-To: <Pine.LNX.4.64.0810090028040.8595@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 9 Oct 2008 00:31:35 +0300 (EEST)

>=20
> More breakage :-), part of timestamps just were previously
> overwritten.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-next-2.6, thanks!
