From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/10] [TCP]: Make lost retrans detection more
 self-contained
Date: Thu, 15 Nov 2007 19:43:14 -0800 (PST)
Message-ID: <20071115.194314.62699193.davem@davemloft.net>
References: <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756217AbXKPDnP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:43:15 -0500
In-Reply-To: <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:29 +0200

> Highest_sack_end_seq is no longer calculated in the loop,
> thus it can be pushed to the worker function altogether
> making that function independent of the sacktag.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Looks good, applied.

Thanks Ilpo.
