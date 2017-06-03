From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next] net: phy: smsc: Implement PHY statistics
Date: Sat, 3 Jun 2017 02:27:15 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA9D0E@CHN-SV-EXMX02.mchp-main.com>
References: <1496438670-30829-1-git-send-email-andrew@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AA9CB9@CHN-SV-EXMX02.mchp-main.com>,<20170603005243.GA3243@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <vivien.didelot@savoirfairelinux.com>,
        <cphealy@gmail.com>, <nikita.yoush@cogentembedded.com>,
        <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:19278 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdFCC1Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 22:27:16 -0400
In-Reply-To: <20170603005243.GA3243@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Just cosmetic thing.
>> How about aligning with other members in structure like
>
>Yes, i can do that. v2 tomorrow sometime.
Thanks.

>
>Can you confirm the LAN911x Internal PHY don't have this. The register
>is not listed in the switch datasheet.
>
This register is NOT in LAN911x internal phy.
http://ww1.microchip.com/downloads/en/DeviceDoc/00002266A.pdf

- Woojung
