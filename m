From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] lan78xx: Use default value loaded from EEPROM/OTP
 when resetting
Date: Thu, 7 Sep 2017 16:13:02 +0200
Message-ID: <20170907141302.GK11248@lunn.ch>
References: <CE371C1263339941885964188A0225FA333A8D@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59599 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754005AbdIGONF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 10:13:05 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA333A8D@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 07:11:50AM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Use default value loaded from EEPROM/OTP when resetting

Hi Nisar

Subject: [PATCH 3/3]

Is this a fix for net, or further development for net-next?

Why do we want the default values?

    Andrew
