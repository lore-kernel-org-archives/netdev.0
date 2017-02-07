From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/3] Documentation: devicetree: Add PHY no lane swap
 binding
Date: Tue, 07 Feb 2017 13:59:39 -0500 (EST)
Message-ID: <20170207.135939.652654768587256313.davem@davemloft.net>
References: <1486444894-12841-1-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, f.fainelli@gmail.com,
        jbrunet@baylibre.com, andrew@lunn.ch, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        u.kleine-koenig@pengutronix.de, martin.blumenstingl@googlemail.com,
        jon.mason@broadcom.com, fabio.estevam@nxp.com
To: lukma@denx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486444894-12841-1-git-send-email-lukma@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lukasz Majewski <lukma@denx.de>
Date: Tue,  7 Feb 2017 06:21:34 +0100

> Add the documentation to avoid PHY lane swapping. This is a boolean
> entry to notify the phy device drivers that the TX/RX lanes NO need
> to be swapped.
> The use case for this binding mostly happens after wrong HW
> configuration of PHY IC during bootstrap.
> 
> Signed-off-by: Lukasz Majewski <lukma@denx.de>

Applied.
