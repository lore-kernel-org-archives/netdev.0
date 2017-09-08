From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH 3/3] lan78xx: Use default value loaded from EEPROM/OTP
 when resetting
Date: Fri, 8 Sep 2017 09:11:48 +0000
Message-ID: <CE371C1263339941885964188A0225FA334438@CHN-SV-EXMX03.mchp-main.com>
References: <CE371C1263339941885964188A0225FA333A8D@CHN-SV-EXMX03.mchp-main.com>
 <20170907141302.GK11248@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>,
        <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:46215 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdIHJMd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 05:12:33 -0400
In-Reply-To: <20170907141302.GK11248@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Sep 07, 2017 at 07:11:50AM +0000, Nisar.Sayed@microchip.com
> wrote:
> > From: Nisar Sayed <Nisar.Sayed@microchip.com>
> >
> > Use default value loaded from EEPROM/OTP when resetting
> 
> Hi Nisar
> 
> Subject: [PATCH 3/3]
> 
> Is this a fix for net, or further development for net-next?
> 
> Why do we want the default values?
> 
>     Andrew

Thanks Andrew,

Yes it is for "net", sorry missed to include it, will update in next version of submit.

These bits are "reset protected" and should not be modified and must use the
Must be configured from EEPROM only. Will update the description.

- Nisar
