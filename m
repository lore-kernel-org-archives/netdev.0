From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/4] net: dsa: Make most functions take a
 dsa_port argument
Date: Wed, 6 Jul 2016 00:30:10 +0200
Message-ID: <20160705223010.GB28825@lunn.ch>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
 <1467756433-25062-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36509 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbcGEWaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 18:30:12 -0400
Content-Disposition: inline
In-Reply-To: <1467756433-25062-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2016 at 03:07:11PM -0700, Florian Fainelli wrote:
> In preparation for allowing platform data, and therefore no valid
> device_node pointer, make most DSA functions takes a pointer to a
> dsa_port structure whenever possible. While at it, introduce a
> dsa_port_is_valid() helper function which checks whether port->dn is
> NULL or not at the moment.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
