From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: phy: use of_mdio_parse_addr
Date: Wed, 31 May 2017 22:01:05 +0200
Message-ID: <20170531200105.GF11230@lunn.ch>
References: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2017 at 03:43:30PM -0400, Jon Mason wrote:
> use of_mdio_parse_addr() in place of an OF read of reg and a bounds
> check (which is litterally the exact same thing that
> of_mdio_parse_addr() does)
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
