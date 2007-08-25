From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] [TCP]: Remove unnecessary wrapper
 tcp_packets_out_dec
Date: Fri, 24 Aug 2007 22:43:26 -0700 (PDT)
Message-ID: <20070824.224326.131923124.davem@davemloft.net>
References: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756673AbXHYFn1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 01:43:27 -0400
In-Reply-To: <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 20 Aug 2007 16:16:29 +0300

> Makes caller side more obvious, there's no need to have
> a wrapper for this oneliner!
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
