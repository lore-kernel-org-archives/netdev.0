From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 1/3] Documentation: devicetree: Add PHY no lane swap
 binding
Date: Tue, 7 Feb 2017 14:02:18 +0100
Message-ID: <20170207130218.GB31560@lunn.ch>
References: <1486444894-12841-1-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        jbrunet <jbrunet@baylibre.com>, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Jon Mason <jon.mason@broadcom.com>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Lukasz Majewski <lukma@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1486444894-12841-1-git-send-email-lukma@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 06:21:34AM +0100, Lukasz Majewski wrote:
> Add the documentation to avoid PHY lane swapping. This is a boolean
> entry to notify the phy device drivers that the TX/RX lanes NO need
> to be swapped.
> The use case for this binding mostly happens after wrong HW
> configuration of PHY IC during bootstrap.

Ah! O.K. Something odd going on with the threading of the patches. 1/3
seems to be last!

> Signed-off-by: Lukasz Majewski <lukma@denx.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
