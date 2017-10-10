From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 1/2] net: phy: DP83822 initial driver submission
Date: Tue, 10 Oct 2017 10:50:02 -0700
Message-ID: <e718326f-f7c2-ede6-be2c-9c1f83a7c44f@gmail.com>
References: <20171010174256.21930-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Woojung.Huh@microchip.com, afd@ti.com
To: Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:47048 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932316AbdJJRuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:50:06 -0400
Received: by mail-qt0-f173.google.com with SMTP id 1so13558866qtn.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:50:05 -0700 (PDT)
In-Reply-To: <20171010174256.21930-1-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2017 10:42 AM, Dan Murphy wrote:
> Add support for the TI  DP83822 10/100Mbit ethernet phy.
> 
> The DP83822 provides flexibility to connect to a MAC through a
> standard MII, RMII or RGMII interface.
> 
> In addition the DP83822 needs to be removed from the DP83848 driver
> as the WoL support is added here for this device.
> 
> Datasheet:
> http://www.ti.com/product/DP83822I/datasheet
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Dan!
-- 
Florian
