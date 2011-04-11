From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] caif: performance bugfix - allow radio stack to
 prioritize packets.
Date: Mon, 11 Apr 2011 13:17:10 -0700 (PDT)
Message-ID: <20110411.131710.260082261.davem@davemloft.net>
References: <1302552691-11874-1-git-send-email-sjur.brandeland@stericsson.com>
	<1302552691-11874-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755649Ab1DKURq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 16:17:46 -0400
In-Reply-To: <1302552691-11874-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: sjur.brandeland@stericsson.com
Date: Mon, 11 Apr 2011 22:11:30 +0200

> From: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
>=20
>     In the CAIF Payload message the Packet Type indication must be se=
t to
>     UNCLASSIFIED in order to allow packet prioritization in the modem=
's
>     network stack. Otherwise TCP-Ack is not prioritized in the modems
>     transmit queue.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
