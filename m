From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH v2] net: broadcom: bnx2x: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 23 Jan 2017 08:16:34 +0000
Message-ID: <BL2PR07MB23062801CB2F195C61C17BDD8D720@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485006196-6472-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Philippe Reynes <tremyfr@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0048.outbound.protection.outlook.com ([104.47.41.48]:59008
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750703AbdAWIQj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 03:16:39 -0500
In-Reply-To: <1485006196-6472-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>=20
> As I don't have the hardware, I'd be very pleased if someone may test thi=
s
> patch.
>=20
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

>From the little testing I've did, things look fine. Thanks.
Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
