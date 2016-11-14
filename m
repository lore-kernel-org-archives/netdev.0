From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] mdio: Demote print from info to debug in
 mdio_driver_register
Date: Mon, 14 Nov 2016 04:44:17 +0100
Message-ID: <20161114034417.GB26710@lunn.ch>
References: <20161114030117.25169-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37358 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752866AbcKNDoT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 22:44:19 -0500
Content-Disposition: inline
In-Reply-To: <20161114030117.25169-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 13, 2016 at 07:01:17PM -0800, Florian Fainelli wrote:
> While it is useful to know which MDIO driver is being registered, demote
> the pr_info() to a pr_debug().
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
