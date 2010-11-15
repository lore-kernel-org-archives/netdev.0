From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: use gre key as flow upper protocol info
Date: Mon, 15 Nov 2010 10:43:22 -0800 (PST)
Message-ID: <20101115.104322.212675424.davem@davemloft.net>
References: <1288795298-323-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756959Ab0KOSm5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 13:42:57 -0500
In-Reply-To: <1288795298-323-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed,  3 Nov 2010 16:41:38 +0200

> The GRE Key field is intended to be used for identifying an individua=
l
> traffic flow within a tunnel. It is useful to be able to have XFRM
> policy selector matches to have different policies for different
> GRE tunnels.
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

I'll apply this to net-next-2.6, thanks.
