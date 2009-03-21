From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net/*: use linux/kernel.h swap()
Date: Sat, 21 Mar 2009 13:36:24 -0700 (PDT)
Message-ID: <20090321.133624.165728995.davem@davemloft.net>
References: <Pine.LNX.4.64.0903192305360.30791@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0903211514370.31762@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41101
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754034AbZCUUgh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 16:36:37 -0400
In-Reply-To: <Pine.LNX.4.64.0903211514370.31762@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 21 Mar 2009 15:16:09 +0200 (EET)

>=20
> tcp_sack_swap seems unnecessary so I pushed swap to the caller.
> Also removed comment that seemed then pointless, and added include
> when not already there. Compile tested.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
