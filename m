From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/4] net: dsa: Pass device pointer to
 dsa_register_switch
Date: Wed, 6 Jul 2016 00:23:00 +0200
Message-ID: <20160705222300.GA28825@lunn.ch>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
 <1467756433-25062-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36502 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755776AbcGEWXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 18:23:03 -0400
Content-Disposition: inline
In-Reply-To: <1467756433-25062-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2016 at 03:07:10PM -0700, Florian Fainelli wrote:
> In preparation for allowing dsa_register_switch() to be supplied with
> device/platform data, pass down a struct device pointer instead of a
> struct device_node.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
