From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Fri, 19 May 2017 17:10:27 -0700
Message-ID: <1f3ea30e-3a58-a6e1-b27c-7833f1fbe858@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40A7C023@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36477 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932298AbdETAKd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 20:10:33 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so4132791wrc.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 17:10:32 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A7C023@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 03:57 PM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> The KSZ9477 is a fully integrated layer 2, managed, 7 ports GigE switch
> with numerous advanced features. 5 ports incorporate 10/100/1000 Mbps PHYs.
> The other 2 ports have interfaces that can be configured as SGMII, RGMII, MII
> or RMII. Either of these may connect directly to a host processor or
> to an external PHY. The SGMII port may interface to a fiber optic transceiver.
> 
> This driver currently supports vlan, fdb, mdb & mirror dsa switch operations.
> 
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>

Looks great, thanks Woojung!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
