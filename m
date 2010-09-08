From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 3)
Date: Wed, 08 Sep 2010 13:09:07 -0700 (PDT)
Message-ID: <20100908.130907.48489776.davem@davemloft.net>
References: <1283521623-1609-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: flameeyes@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753632Ab0IHUIt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 16:08:49 -0400
In-Reply-To: <1283521623-1609-1-git-send-email-flameeyes@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Diego Elio Petten=F2 <flameeyes@gmail.com>
Date: Fri,  3 Sep 2010 15:47:03 +0200

> From: Diego Elio 'Flameeyes' Petten=F2 <flameeyes@gmail.com>
>=20
> This simple patch copies the current approach for SIOCINQ ioctl() fro=
m DCCP
> into SCTP so that the userland code working with SCTP can use a simil=
ar
> interface across different protocols to know how much space to alloca=
te for
> a buffer.
>=20
> Signed-off-by: Diego Elio Petten=F2 <flameeyes@gmail.com>

Applied, thank you.
