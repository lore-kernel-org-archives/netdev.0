From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [NET]: Remove obsolete comment
Date: Sat, 05 Jan 2008 23:18:22 -0800 (PST)
Message-ID: <20080105.231822.13216596.davem@davemloft.net>
References: <Pine.LNX.4.64.0801051418140.32403@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751431AbYAFHSW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 02:18:22 -0500
In-Reply-To: <Pine.LNX.4.64.0801051418140.32403@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 5 Jan 2008 14:21:48 +0200 (EET)

> [PATCH] [NET]: Remove obsolete comment
>=20
> It seems that ip_build_xmit is no longer used in here and
> ip_append_data is used.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>=20
> Hi Dave,
>=20
> While reading some nearby code, I noticed this. I'm not 100%
> sure if the removal is valid or not nor have interest to dig
> it up from history but I suppose you know it better without
> having to look it up from history :-).

It's definitely obsolete cruft, good catch, applied :-)
