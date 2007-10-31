From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [TCP]: Another TAGBITS -> SACKED_ACKED|LOST
 conversion
Date: Wed, 31 Oct 2007 02:51:30 -0700 (PDT)
Message-ID: <20071031.025130.180934983.davem@davemloft.net>
References: <Pine.LNX.4.64.0710311136200.16864@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0710311149020.16864@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43078
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753741AbXJaJva convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 05:51:30 -0400
In-Reply-To: <Pine.LNX.4.64.0710311149020.16864@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 31 Oct 2007 11:49:59 +0200 (EET)

> Similar to commit 3eec0047d9bdd, point of this is to avoid
> skipping R-bit skbs.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I'll apply this also, thanks a lot.
