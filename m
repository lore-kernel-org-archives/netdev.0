From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] Revert "rndis_host: Poll status channel
 before control channel"
Date: Fri, 02 Jul 2010 21:48:21 -0700 (PDT)
Message-ID: <20100702.214821.267383361.davem@davemloft.net>
References: <1278110361.4878.73.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pitxyoki@gmail.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57787
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750795Ab0GCEsI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jul 2010 00:48:08 -0400
In-Reply-To: <1278110361.4878.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 02 Jul 2010 23:39:21 +0100

> This reverts commit c17b274dc2aa538b68c1f02b01a3c4e124b435ba.
>=20
> That change was reported to break rndis_wlan support for the WUSB54GS=
=2E
>=20
> Reported-by: Lu=EDs Picciochi Oliveira <pitxyoki@gmail.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

So I wasn't completely crazy when I wanted more testing feedback
for this change :-)

Applied, thanks Ben.
