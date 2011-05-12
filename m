From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: convert to ndo_fix_features
Date: Thu, 12 May 2011 15:46:33 -0700 (PDT)
Message-ID: <20110512.154633.39181232.davem@davemloft.net>
References: <20110506175629.BC59D1389B@rere.qmqm.pl>
	<20110507132217.0CB5A13A69@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53060
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751880Ab1ELWrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:47:05 -0400
In-Reply-To: <20110507132217.0CB5A13A69@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat,  7 May 2011 15:22:17 +0200 (CEST)

> This should also fix updating of vlan_features and propagating change=
s to
> VLAN devices on the bond.
>=20
> Side effect: it allows user to force-disable some offloads on the bon=
d                                   =20
> interface.                                                           =
                                    =20
>                                                                      =
                                    =20
> Note: NETIF_F_VLAN_CHALLENGED is managed by bond_fix_features() now. =
                                    =20
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
