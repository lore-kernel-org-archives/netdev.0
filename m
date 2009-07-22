From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: Add comments to (near) all functions in
 tcp_output.c v3
Date: Wed, 22 Jul 2009 09:32:04 -0700 (PDT)
Message-ID: <20090722.093204.144479345.davem@davemloft.net>
References: <20090722090040.GA17474@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753080AbZGVQb7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 12:31:59 -0400
In-Reply-To: <20090722090040.GA17474@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andi Kleen <andi@firstfloor.org>
Date: Wed, 22 Jul 2009 11:00:40 +0200

> TCP: Add comments to (near) all functions in tcp_output.c v3
>=20
> While looking for something else I spent some time adding
> one liner comments to the tcp_output.c functions that
> didn't have any. That makes the comments more consistent.
>=20
> I hope I documented everything right.
>=20
> No code changes.
>=20
> v2: Incorporated feedback from Ilpo.
> v3: Change style of one liner comments, add a few more comments.
>=20
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-next-2.6, thanks!

