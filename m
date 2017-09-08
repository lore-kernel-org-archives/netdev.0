From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH net] smsc95xx: Configure pause time to 0xffff when tx
 flow control enabled
Date: Fri, 8 Sep 2017 09:11:37 +0000
Message-ID: <CE371C1263339941885964188A0225FA33442C@CHN-SV-EXMX03.mchp-main.com>
References: <CE371C1263339941885964188A0225FA3339DB@CHN-SV-EXMX03.mchp-main.com>
 <20170907135658.GG11248@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>,
        <netdev@vger.kernel.org>, <steve.glendinning@shawell.net>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:20067 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750937AbdIHJMX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 05:12:23 -0400
In-Reply-To: <20170907135658.GG11248@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Sep 07, 2017 at 06:51:37AM +0000, Nisar.Sayed@microchip.com
> wrote:
> > From: Nisar Sayed <Nisar.Sayed@microchip.com>
> >
> > Configure pause time to 0xffff when tx flow control enabled
> 
> Hi Nisar
> 
> You should explain the 'Why' in the commit message. Why do we want a
> pause time of 0xffff?
> 
>       Andrew

Thanks Andrew,

I shall update the description and submit next version.

- Nisar
