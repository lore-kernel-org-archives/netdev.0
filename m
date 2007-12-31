From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] [TCP]: Rename update_send_head & include related
 increment to it
Date: Mon, 31 Dec 2007 04:44:58 -0800 (PST)
Message-ID: <20071231.044458.232409947.davem@davemloft.net>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758097AbXLaMo7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 07:44:59 -0500
In-Reply-To: <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 31 Dec 2007 12:47:50 +0200

> There's very little need to have the packets_out incrementing in
> a separate function. Also name the combined function
> appropriately.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
