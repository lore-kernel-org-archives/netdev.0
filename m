From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v3 1/2] qed: Add infrastructure for PTP support.
Date: Tue, 7 Feb 2017 07:03:17 +0000
Message-ID: <BL2PR07MB230614EEE9044CA39444C69E8D430@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485848869-22834-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485848869-22834-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170202125637.GA3191@netboy>
 <BL2PR07MB2306F69350DA91B9B2A2E3588D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB2306BFF942FD6EE54400D1288D400@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170207064440.GA1853@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0053.outbound.protection.outlook.com ([104.47.33.53]:23168
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751164AbdBGHDU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 02:03:20 -0500
In-Reply-To: <20170207064440.GA1853@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, Feb 06, 2017 at 10:41:44AM +0000, Mintz, Yuval wrote:
> > Richard - we're planning on sending v4 with the existing algorithm
> > [but without iterating on 'val =3D=3D 0']; If you have any suggestion f=
or
> > improving this, please share it.
>=20
> Sorry, haven't had the time to look at your issue.
>=20
> BTW, you said you think the performance impact is small, but did you
> measure it on typical HW?

Can't say we've focused on performance testing for the feature,
but regular testing showed sane results.
