From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 13/17] tcp: kill eff_sacks "cache", the sole
 user can calculate itself
Date: Mon, 02 Mar 2009 03:02:40 -0800 (PST)
Message-ID: <20090302.030240.255087057.davem@davemloft.net>
References: <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757415AbZCBLC6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:02:58 -0500
In-Reply-To: <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:38 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Also fixes insignificant bug that would cause sending of stale
> SACK block (would occur in some corner cases).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
