From: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Subject: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 08:50:34 +0000
Message-ID: <1480495831.3563.135.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0085.outbound.protection.outlook.com ([104.47.42.85]:29312
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754558AbcK3LYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 06:24:09 -0500
Content-Language: en-US
Content-ID: <E8350BC05425784D9DFC5796ADC2BA60@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to wrap my head around these two "devices" and have a hard time=
 telling them apart.
We are looking att adding a faily large switch(over PCIe) to our board and =
from what I can tell
switchdev is the new way to do it but DSA is still there. Is it possible to=
 just list
how they differ?

What can switchdev do that DSA cannot?

What can DSA do that switchdev cannot?


Can one enable switchdev and dsa for the same switch device?

 Jocke=20
