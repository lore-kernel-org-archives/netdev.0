From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND v6 0/7] net: cpsw: Support for am335x chip MACIDs
Date: Tue, 30 Sep 2014 01:31:13 -0400 (EDT)
Message-ID: <20140930.013113.1095845408759260547.davem@davemloft.net>
References: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcousson@baylibre.com, tony@atomide.com, wsa@the-dreams.de,
	rostedt@goodmis.org, mugunthanvnm@ti.com,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: mpa@pengutronix.de
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Pargmann <mpa@pengutronix.de>
Date: Mon, 29 Sep 2014 08:53:12 +0200

> Another resend of this series to add the netdev list.
> 
> This series adds support to the cpsw driver to read the MACIDs of the am335x
> chip and use them as fallback. These addresses are only used if there are no
> mac addresses in the devicetree, for example set by a bootloader.

Series applied to net-next, thanks.
