From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] [TCP]: Make invariant check complain about invalid
 sacked_out
Date: Mon, 31 Dec 2007 04:44:49 -0800 (PST)
Message-ID: <20071231.044449.74206505.davem@davemloft.net>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753319AbXLaMou convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 07:44:50 -0500
In-Reply-To: <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 31 Dec 2007 12:47:49 +0200

> Earlier resolution for NewReno's sacked_out should now keep
> it small enough for this to become invariant-like check.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
