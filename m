From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix/garbage: kill copy of the skb queue walker
Date: Mon, 03 May 2010 15:40:12 -0700 (PDT)
Message-ID: <20100503.154012.184444011.davem@davemloft.net>
References: <alpine.DEB.2.00.1005031620130.7041@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756922Ab0ECWkF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 18:40:05 -0400
In-Reply-To: <alpine.DEB.2.00.1005031620130.7041@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 3 May 2010 16:22:18 +0300 (EEST)

> Worse yet, it seems that its arguments were in reverse order. Also
> remove one related helper which seems hardly worth keeping.
>=20
> Compile tested.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
