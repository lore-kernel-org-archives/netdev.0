From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 4/5] dsa: Microchip KSZ switches SPI devicetree
 configuration
Date: Sun, 7 May 2017 01:04:26 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A5C2D9@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40A5C00B@CHN-SV-EXMX02.mchp-main.com>,<1ade6f7e-7a28-db47-3811-d35d90f57b56@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <sergei.shtylyov@cogentembedded.com>, <andrew@lunn.ch>,
        <f.fainelli@gmail.com>, <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:29888 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751412AbdEGW1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:27:18 -0400
In-Reply-To: <1ade6f7e-7a28-db47-3811-d35d90f57b56@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei

>> +             spi1: spi@f8008000 {
>> +             pinctrl-0 = <&pinctrl_spi_ksz>;
>> +             cs-gpios = <&pioC 25 0>;
>> +             id = <1>;
>> +             status = "okay";
>
>    4 lines above should be indented more to the right.
>> +             };
>> +             };
>
>    Unmatched }?

Will fix both.

- Woojung
