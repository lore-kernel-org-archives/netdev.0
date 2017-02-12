From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 12 Feb 2017 11:52:23 +0000
Message-ID: <BL2PR07MB230689D83356C4577C8AB1E58D460@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
 <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0078.outbound.protection.outlook.com ([104.47.41.78]:21540
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751137AbdBLLw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 06:52:26 -0500
In-Reply-To: <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The '+8' is not some sort of rounding correction, but rather part of the
> required configuration.

Just to clarify [since it's bit a meaningless otherwise] -
this +8 is a HW-bug workaround.
