From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 4/6] net: phy: Use phy name when requesting the
 interrupt
Date: Wed, 28 Sep 2016 10:18:33 -0700
Message-ID: <4f9fd0d1-3c75-30d2-5d8c-047474d6b653@gmail.com>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:32848 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932977AbcI1RSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 13:18:35 -0400
Received: by mail-pa0-f67.google.com with SMTP id oz2so2306663pac.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 10:18:35 -0700 (PDT)
In-Reply-To: <1475051544-18561-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2016 01:32 AM, Andrew Lunn wrote:
> Using the fixed name "phy_interrupt" is not very informative in
> /proc/interrupts when there are a lot of phys, e.g. a device with an
> Ethernet switch. So when requesting the interrupt, use the name of the
> phy.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
