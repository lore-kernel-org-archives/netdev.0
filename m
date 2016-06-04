From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/9] net: dsa: Provide unique DSA slave MII bus
 names
Date: Sat, 4 Jun 2016 22:00:54 +0200
Message-ID: <20160604200054.GE2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59630 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbcFDUA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 16:00:56 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 03, 2016 at 05:05:25PM -0700, Florian Fainelli wrote:
> In case we have multiples trees and switches with the same index, we
> need to add another discriminating id: the switch tree.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

     Andrew
