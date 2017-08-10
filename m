From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] phylink: Fix an uninitialized variable bug
Date: Thu, 10 Aug 2017 17:21:12 +0200
Message-ID: <20170810152112.GF24790@lunn.ch>
References: <20170809213550.rga6tlohagu2pm2y@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk+kernel@arm.linux.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59765 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752806AbdHJPVT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 11:21:19 -0400
Content-Disposition: inline
In-Reply-To: <20170809213550.rga6tlohagu2pm2y@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 12:35:50AM +0300, Dan Carpenter wrote:
> "ret" isn't necessarily initialized here.
> 
> Fixes: 9525ae83959b ("phylink: add phylink infrastructure")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
