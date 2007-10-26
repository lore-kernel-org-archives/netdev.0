From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make tcp_match_skb_to_sack() static
Date: Fri, 26 Oct 2007 03:57:45 -0700 (PDT)
Message-ID: <20071026.035745.216735808.davem@davemloft.net>
References: <20071024162358.GA30533@stusta.de>
	<Pine.LNX.4.64.0710242102530.11009@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bunk@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751561AbXJZK5n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 06:57:43 -0400
In-Reply-To: <Pine.LNX.4.64.0710242102530.11009@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 25 Oct 2007 00:39:23 +0300 (EEST)

> On Wed, 24 Oct 2007, Adrian Bunk wrote:
>=20
> > tcp_match_skb_to_sack() can become static.
> >=20
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> >
> [...snip...]
>=20
> Thanks, I should have noticed that right from the beginning...

Yep, applied, thanks!
