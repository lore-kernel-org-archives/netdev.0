From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: convert xen-netfront to hw_features
Date: Fri, 01 Apr 2011 20:54:55 -0700 (PDT)
Message-ID: <20110401.205455.70198735.davem@davemloft.net>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jeremy.fitzhardinge@citrix.com,
	konrad.wilk@oracle.com, Ian.Campbell@citrix.com,
	xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753011Ab1DBDzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:55:32 -0400
In-Reply-To: <20110331110136.03A1A13A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)

> Not tested in any way. The original code for offload setting seems br=
oken
> as it resets the features on every netback reconnect.
>=20
> This will set GSO_ROBUST at device creation time (earlier than connec=
t time).
>=20
> RX checksum offload is forced on - so advertise as it is.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
