From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] [TCP]: Update comment about highest_sack
 validity
Date: Fri, 10 Aug 2007 14:31:38 -0700 (PDT)
Message-ID: <20070810.143138.126762970.davem@davemloft.net>
References: <Pine.LNX.4.64.0708101428540.20173@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751073AbXHJVbo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 17:31:44 -0400
In-Reply-To: <Pine.LNX.4.64.0708101428540.20173@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 10 Aug 2007 14:30:46 +0300 (EEST)

>=20
> This stale info came from the original idea, which proved to be
> unnecessarily complex, sacked_out > 0 is easy to do and that when
> it's going to be needed anyway (it _can_ be valid also when
> sacked_out =3D=3D 0 but there's not going to be a guarantee about it
> for now).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Patch applied to net-2.6.24
