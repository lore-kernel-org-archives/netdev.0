From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 4/5][SOCK]: Drop inuse pcounter from struct
 proto (v2).
Date: Fri, 28 Mar 2008 16:40:37 -0700 (PDT)
Message-ID: <20080328.164037.39924599.davem@davemloft.net>
References: <47ECE67A.2030503@openvz.org>
	<47ED28C2.4060303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51118
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756359AbYC1Xkl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 19:40:41 -0400
In-Reply-To: <47ED28C2.4060303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 28 Mar 2008 18:20:02 +0100

> Pavel Emelyanov a =E9crit :
> > An uppercut - do not use the pcounter on struct proto.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >
> >  =20
> Thanks a lot Pavel for this excellent work.
>=20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
