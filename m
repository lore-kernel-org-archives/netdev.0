From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Subject: RE: [PATCH net-next V4 00/10] liquidio CN23XX support
Date: Wed, 31 Aug 2016 21:49:13 +0000
Message-ID: <DM3PR07MB2138F4309F8E7E73255471CA81E30@DM3PR07MB2138.namprd07.prod.outlook.com>
References: <1472666609-19503-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <20160831.141304.936698663361263678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0077.outbound.protection.outlook.com ([104.47.40.77]:60778
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751997AbcHaWEu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 18:04:50 -0400
In-Reply-To: <20160831.141304.936698663361263678.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Much.=20

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, August 31, 2016 2:13 PM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next V4 00/10] liquidio CN23XX support
>=20
> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> Date: Wed, 31 Aug 2016 11:03:19 -0700
>=20
> > Following patchset adds support for new device "CN23XX" in liquidio
> > family of adapters. As adviced by you I have split the previous V3
> > patch of 18 patches into two halves. This first patchset has first 10
> > patches, which are tested against net-next. I will post the second
> > half after this one.
> >
> > This V4 patch also addressed all the comments from previous
> > submission:
> > 1) Avoid busy loop while reading registers.
> > 2) Other minor comments about debug messages and constants.
> >
> > Please apply patches in following order as some of the patches depend
> > on earlier patches.
>=20
> Series applied, thanks.
