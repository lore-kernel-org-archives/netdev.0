From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 00/10] qed/qede updates
Date: Tue, 23 May 2017 06:46:53 +0000
Message-ID: <BLUPR0701MB2004B78FE1E4D2CB28BDFE6C8DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
 <20170521.130141.1217220690269746260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0053.outbound.protection.outlook.com ([104.47.41.53]:37184
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965905AbdEWGqz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:46:55 -0400
In-Reply-To: <20170521.130141.1217220690269746260.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  - #1, #2 and #9 correct small missing ethtool functionality.
> >  - #3, #6  and #8 correct minor issues in driver, but those are either
> >    print-related or unexposed in existing code.
> >  - #4 adds proper support to TLB mode bonding.
> >  - #10 is meant to improve performance on varying cache-line sizes.
> >
> > Dave,
> >
> > Please consider applying this to `net-next'.
>=20
> Series applied, thank you.

Just noticed I never actually sent #10... [as a result, you've applied #1-#=
9].
Will send it 'again' in a later series.
