From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net:mv88e6xxx: use g2 interrupt for 6097 chip
Date: Wed, 7 Dec 2016 15:01:30 +0100
Message-ID: <20161207140130.GI18817@lunn.ch>
References: <1481095626-7823-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@gmail.com
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47811 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751590AbcLGOCM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 09:02:12 -0500
Content-Disposition: inline
In-Reply-To: <1481095626-7823-1-git-send-email-volodymyr.bendiuga@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 08:27:06AM +0100, Volodymyr Bendiuga wrote:
> This chip needs MV88E6XXX_FLAG_G2_INT
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
