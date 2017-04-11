From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: micrel: KSZ9031: fix crash when statistic
 requested
Date: Tue, 11 Apr 2017 18:36:28 +0200
Message-ID: <20170411163628.GL27307@lunn.ch>
References: <20170410233324.1178-1-grygorii.strashko@ti.com>
 <e821198e-5a61-7912-d120-205f66c02650@gmail.com>
 <050b6778-276b-7094-36e1-1ccd06364766@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55201 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751101AbdDKQgf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 12:36:35 -0400
Content-Disposition: inline
In-Reply-To: <050b6778-276b-7094-36e1-1ccd06364766@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've considered all this option, honestly, but I do not know if this
> phys (issue should affect KSZ886X, KSZ8873MLL, KSZ9031, KSZ9021, KSZ8061, KS8737)
> support fetching statistics or not and was hoping to get feedback from community.

Hi Grygorii

Microchip are one of the good guys. All there datesheets are open. So
you should be able to check this.

    Andrew
