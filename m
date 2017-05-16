From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] bnx2x: Remove open coded carrier check
Date: Tue, 16 May 2017 12:54:39 +0000
Message-ID: <BLUPR0701MB200418719E57840FFDABDC0C8DE60@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170516122056.1534-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0066.outbound.protection.outlook.com ([104.47.40.66]:50156
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752183AbdEPMym (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 08:54:42 -0400
In-Reply-To: <20170516122056.1534-1-leon@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is inline function to test if carrier present, so it makes open-cod=
ed
> solution redundant.
>=20
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

Thanks Leon.

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
