From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe warning in net-next
Date: Tue, 26 May 2009 21:06:07 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0905262104540.9428@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090526.205748.115287307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="110125-30809-1243397167=:9428"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24218 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbZE0EGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 00:06:07 -0400
In-Reply-To: <20090526.205748.115287307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--110125-30809-1243397167=:9428
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 26 May 2009, David Miller wrote:

>=20
> Please fix this:
>=20
> drivers/net/ixgbe/ixgbe_main.c: In function =E2=80=98ixgbe_probe=E2=80=99=
:
> drivers/net/ixgbe/ixgbe_main.c:5357: warning: label =E2=80=98err_hw_init=
=E2=80=99 defined but not used
>=20

I already have a patch in Jeff's queue that fixes this.  Sorry for the=20
clutter; it should be pushed very soon.

Cheers,
-PJ
--110125-30809-1243397167=:9428--
