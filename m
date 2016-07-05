From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 4/4] net: dsa: Move ports assignment closer
 to error checking
Date: Wed, 6 Jul 2016 00:37:10 +0200
Message-ID: <20160705223710.GD28825@lunn.ch>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
 <1467756433-25062-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36519 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbcGEWhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 18:37:11 -0400
Content-Disposition: inline
In-Reply-To: <1467756433-25062-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2016 at 03:07:13PM -0700, Florian Fainelli wrote:
> Move the assignment of ports in _dsa_register_switch() closer to where
> it is checked, no functional change. Re-order declarations to be
> preserve the inverted christmas tree style.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
