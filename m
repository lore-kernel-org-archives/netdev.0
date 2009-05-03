From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] powerpc: convert mace to netdev_ops
Date: Sun, 03 May 2009 14:20:29 -0700 (PDT)
Message-ID: <20090503.142029.245176169.davem@davemloft.net>
References: <20090427.054258.16622932.davem@davemloft.net>
	<20090503114820.GA14926@ime.usp.br>
	<20090503.141524.253766195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, paulus@samba.org
To: rbrito@ime.usp.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753651AbZECVUe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2009 17:20:34 -0400
In-Reply-To: <20090503.141524.253766195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Sun, 03 May 2009 14:15:24 -0700 (PDT)

> From: Rog=E9rio Brito <rbrito@ime.usp.br>
> Date: Sun, 3 May 2009 08:48:20 -0300
>=20
>> I hope that this version is a slightly better fix to convert mace to
>> netdev_ops.
>>=20
>> This is against this morning's net-2.6 tree.
>>=20
>> Signed-off-by: Rog=E9rio Brito <rbrito@ime.usp.br>
>=20
> I'll apply this, thanks!  I made one change however.

Oh, nevermind, it seems that MACE was already converted
to netdev_ops some time ago in the net-next-2.6 tree.
