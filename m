From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: marvell: Add support for 88e1545 PHY
Date: Wed, 1 Feb 2017 18:22:57 -0800
Message-ID: <24fe9ef6-a81e-f59a-ac3f-d3f8bf2f25ef@gmail.com>
References: <1485992103-23331-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35300 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBBCW7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:22:59 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so321882pge.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 18:22:59 -0800 (PST)
In-Reply-To: <1485992103-23331-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2017 03:35 PM, Andrew Lunn wrote:
> The 88e1545 PHYs are discrete Marvell PHYs, found in a quad package on
> the zii-devel-b board. Add support for it to the Marvell PHY driver.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
