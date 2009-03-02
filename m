From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 09/17] tcp: cleanup ca_state mess in tcp_timer
Date: Mon, 02 Mar 2009 03:02:12 -0800 (PST)
Message-ID: <20090302.030212.130303278.davem@davemloft.net>
References: <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757245AbZCBLCa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:02:30 -0500
In-Reply-To: <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:34 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Redundant checks made indentation impossible to follow.
> However, it might be useful to make this ca_state+is_sack
> indexed array.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
