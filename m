From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Tue, 18 Apr 2017 23:18:08 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A488FD@CHN-SV-EXMX02.mchp-main.com>
References: <20170418171706.21190-1-james.hughes@raspberrypi.org>
         <1492541921.10587.135.camel@edumazet-glaptop3.roam.corp.google.com>
         <9235D6609DB808459E95D78E17F2E43D40A477A5@CHN-SV-EXMX02.mchp-main.com>
 <1492555561.10587.147.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <james.hughes@raspberrypi.org>, <netdev@vger.kernel.org>,
        <steve.glendinning@shawell.net>, <UNGLinuxDriver@microchip.com>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:51781 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751645AbdDRXSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 19:18:10 -0400
In-Reply-To: <1492555561.10587.147.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBpZiAoaW5mby0+dHhfZml4dXApIHsNCj4gICAgc2tiID0gaW5mby0+dHhfZml4dXAgKGRldiwg
c2tiLCBHRlBfQVRPTUlDKTsNCj4gDQo+ICAgIGlmICghc2tiKSB7IC8vIE5vdGUgdGhhdCBza2Ig
aXMgTlVMTCBub3cNCg0KWW91IGFyZSByaWdodC4gc2tiICBpcyByZXR1cm4gdmFsdWUgb2YgdHhf
Zml4dXAoKS4NCg0KLSBXb29qdW5nDQo=
