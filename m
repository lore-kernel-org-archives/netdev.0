From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/8] net: phy: Add 2000base-x, 2500base-x and
 rxaui modes
Date: Fri, 20 Jan 2017 16:07:21 -0800
Message-ID: <85759cc7-41ab-ed0d-fced-811cad451adb@gmail.com>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
 <1484955062-26718-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34381 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750982AbdAUAQr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:16:47 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so6256597pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 16:16:40 -0800 (PST)
In-Reply-To: <1484955062-26718-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2017 03:30 PM, Andrew Lunn wrote:
> The mv88e6390 ports 9 and 10 supports some additional PHY modes. Add
> these modes to the PHY core so they can be used in the binding.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Can you also send a Device Tree specification patch with these updates?
Thanks!
-- 
Florian
