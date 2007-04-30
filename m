From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP] FRTO: Delay skb available check until it's
 mandatory
Date: Mon, 30 Apr 2007 00:40:12 -0700 (PDT)
Message-ID: <20070430.004012.102465315.davem@davemloft.net>
References: <11762834448-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423118AbXD3HkP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 03:40:15 -0400
In-Reply-To: <11762834448-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 11 Apr 2007 12:24:03 +0300

> No new data is needed until the first ACK comes, so no need to
> check for application limitedness until then.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
