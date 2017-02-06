From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] Documentation: devicetree: Add PHY no lane swap binding
Date: Mon, 6 Feb 2017 15:38:35 +0100
Message-ID: <20170206143835.GI32506@lunn.ch>
References: <1486223267-11875-1-git-send-email-lukma@denx.de>
 <20170204172329.GA8364@lunn.ch>
 <509fadc4-164c-7333-1871-fd6e615e57c9@gmail.com>
 <20170206151524.2ff0f799@jawa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
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
In-Reply-To: <20170206151524.2ff0f799@jawa>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Since this is a description of the hardware, absence of a properties
> > should mean that the driver is at freedom to either keep the hardware
> > defaults, or come up with its own settings that are sensible for that
> > particular PHY device.
> > 
> > What would you see clarified here?
> 
> Any more comments to this patch?

Nope.

	Andrew
