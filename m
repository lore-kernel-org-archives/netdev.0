From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP]: Add two new spurious RTO responses to FRTO
Date: Fri, 02 Mar 2007 13:27:46 -0800 (PST)
Message-ID: <20070302.132746.99205477.davem@davemloft.net>
References: <20070228121302.GA2983@ff.dom.local>
	<Pine.LNX.4.64.0703011312250.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@o2.pl, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965632AbXCBV1r convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 16:27:47 -0500
In-Reply-To: <Pine.LNX.4.64.0703011312250.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 1 Mar 2007 13:30:20 +0200 (EET)

> [PATCH] [TCP]: Complete icsk-to-local-variable change (in tcp_enter_c=
wr)
>=20
> A local variable for icsk was created but this change was
> missing. Spotted by Jarek Poplawski.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to tcp-2.6, thank you.
