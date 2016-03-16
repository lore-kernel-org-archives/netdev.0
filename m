From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 0/5] net: macb: Checkpatch cleanups
Date: Wed, 16 Mar 2016 14:39:49 +0100
Message-ID: <56E96225.2040508@atmel.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <michal.simek@xilinx.com>, <joe@perches.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/03/2016 20:10, Moritz Fischer a =E9crit :
> Hi all,
>=20
> I backed out the variable scope changes and made a separate
> patch for the ether_addr_copy change.
>=20
> Changes from v1:

As it's v2, it's better to add it in each subject of the patch series l=
ike:
"[PATCH v2 0/5] net: macb: Checkpatch cleanups"


> * Backed out variable scope changes
> * Separated out ether_addr_copy into it's own commit
> * Fixed typo in comments as suggested by Joe
>=20
> Cheers,
>=20
> Moritz
>=20
> Moritz Fischer (5):
>   net: macb: Fix coding style error message
>   net: macb: Fix coding style warnings
>   net: macb: Address checkpatch 'check' suggestions
>   net: macb: Use ether_addr_copy over memcpy
>   net: macb: Fix simple typo.
>=20
>  drivers/net/ethernet/cadence/macb.c | 153 +++++++++++++++++---------=
----------
>  1 file changed, 70 insertions(+), 83 deletions(-)
>=20


--=20
Nicolas Ferre
