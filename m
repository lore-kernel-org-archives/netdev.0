From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next v6 0/2] qed*: Add support for PTP
Date: Tue, 14 Feb 2017 20:12:52 +0000
Message-ID: <BL2PR07MB230680F7B0E85799B0DA58C48D580@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1487088205-21578-1-git-send-email-Yuval.Mintz@cavium.com>,<20170214.144351.675778032610245493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0064.outbound.protection.outlook.com ([104.47.36.64]:18958
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755031AbdBNUM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 15:12:56 -0500
In-Reply-To: <20170214.144351.675778032610245493.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This patch series adds required changes for qed/qede drivers for
> > supporting the IEEE Precision Time Protocol (PTP).
> >=20
> > Dave,
> > Please consider applying this series to "net-next".

> Please fix the problems reported by the kbuild robot.

> Thanks.

Fixing those are trivial [simply setting the variables to 0 on declaration]=
,
but I actually believe those are false positives.
Still, if you want me to re-spin v7 for this - I'll send it tomorrow.
