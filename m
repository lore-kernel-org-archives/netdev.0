From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: convert to hw_features
Date: Fri, 01 Apr 2011 20:58:00 -0700 (PDT)
Message-ID: <20110401.205800.35038485.davem@davemloft.net>
References: <20110331110135.890D113A67@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753134Ab1DBD6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:58:38 -0400
In-Reply-To: <20110331110135.890D113A67@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)

> This should probably get TSO available as it's basically a loopback d=
evice.
> Offloads are left disabled by default - as before.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
