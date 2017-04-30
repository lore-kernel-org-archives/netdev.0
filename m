From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH v1 1/3] bnx2x: Replace custom scnprintf()
Date: Sun, 30 Apr 2017 08:16:36 +0000
Message-ID: <BLUPR0701MB2004B5244F758FC95EE1B5E88D150@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0048.outbound.protection.outlook.com ([104.47.40.48]:22235
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1167087AbdD3IQk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:16:40 -0400
In-Reply-To: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Andy Shevchenko <andy.shevchenko@gmail.com>
>=20
> Use scnprintf() when printing version instead of custom open coded varian=
ts.
>=20
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Hi Andy this seems correct.
Was there a cover-letter for your series? I've failed to find it.
[I was mostly interested in your motivation for this kind of cleanup]

Anyway, thanks.
Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
