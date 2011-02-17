From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bnx2x: Support for managing RX indirection table
Date: Thu, 17 Feb 2011 12:49:56 -0800 (PST)
Message-ID: <20110217.124956.226782810.davem@davemloft.net>
References: <alpine.DEB.2.00.1102161210190.31937@pokey.mtv.corp.google.com>
	<1297933764.2670.20.camel@edumazet-laptop>
	<1297947524.4722.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53591
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757962Ab1BQUtU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 15:49:20 -0500
In-Reply-To: <1297947524.4722.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Eilon Greenstein" <eilong@broadcom.com>
Date: Thu, 17 Feb 2011 14:58:44 +0200

> On Thu, 2011-02-17 at 01:09 -0800, Eric Dumazet wrote:
>> Le mercredi 16 f=E9vrier 2011 =E0 12:27 -0800, Tom Herbert a =E9crit=
 :
>> > Support fetching and retrieving RX indirection table via ethtool.
>> >=20
>> > Signed-off-by: Tom Herbert <therbert@google.com>
>> > ---
>> >  drivers/net/bnx2x/bnx2x.h         |    2 +
>> >  drivers/net/bnx2x/bnx2x_ethtool.c |   56 ++++++++++++++++++++++++=
+++++++++++++
>> >  drivers/net/bnx2x/bnx2x_main.c    |   22 +++++++++++---
>> >  3 files changed, 75 insertions(+), 5 deletions(-)
>>=20
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Acked-by: Eilon Greenstein <eilong@broadcom.com>
>=20
> Thanks everyone!=20

Applied to net-next-2.6, thanks!
