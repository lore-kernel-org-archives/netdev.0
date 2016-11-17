From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next] lan78xx: relocate mdix setting to phy driver
Date: Thu, 17 Nov 2016 14:16:18 -0800
Message-ID: <43b475ac-fea4-aaa1-264c-bd14994d448e@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40966AA4@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36244 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbcKQWQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 17:16:21 -0500
Received: by mail-pf0-f195.google.com with SMTP id c4so9627230pfb.3
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 14:16:21 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40966AA4@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 02:10 PM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> Relocate mdix code to phy driver to be called at config_init().
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
