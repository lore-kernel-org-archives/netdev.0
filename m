From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 00/10] qed*: Bug fixes
Date: Mon, 20 Feb 2017 20:14:17 +0000
Message-ID: <BL2PR07MB23065BFB31B2BC1031663D7D8D5E0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
 <20170220.103739.96795933381020391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0040.outbound.protection.outlook.com ([104.47.37.40]:49984
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751403AbdBTUOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 15:14:25 -0500
In-Reply-To: <20170220.103739.96795933381020391.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > Hi Dave,
> >
> > The 3 first patches here are a repost of
> > ("qed: RoCE infrastructure fixes"). The fourth is an additional
> > RoCE-related infrastructure fix, and the latter contain various fixes
> > to qed/qede.
> >
> > Notice patch #10 will create a conflict when net and net-next would be
> > merged [although its fix is quite trivial].
> >
> > Please consider applying these to `net'.
>=20
> Linus made his release so all patches are going into net-next, which this
> series doesn't apply cleanly to.  Please therefore respin your series aga=
inst
> net-next, thanks.

Just to clarify - do you want me to re-spin the fixes against next-next *no=
w*,
or do you want me to wait until it re-opens? [not sure on its exact state]
