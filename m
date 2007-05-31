From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] [TCP]: Reorganize lost marking code
Date: Thu, 31 May 2007 01:44:03 -0700 (PDT)
Message-ID: <20070531.014403.123678086.davem@davemloft.net>
References: <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754729AbXEaInt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 04:43:49 -0400
In-Reply-To: <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 May 2007 11:35:59 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> The indentation started to get scary, so I reorganized code so
> that some trivial ifs are in tcp_update_scoreboard and the main
> loops remain in tcp_update_scoreboard_fack.
>=20
> It's much easier to view the actual changes with git-diff -w
> than from the messy looking (default) diff.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
