From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 04/13] ARM: dts: dra7: Add syscon regmap for CORE CONTROL
 area
Date: Mon, 8 Sep 2014 10:47:03 -0700
Message-ID: <20140908174702.GJ3238@atomide.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
 <1410185442-907-5-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wg@grandegger.com, mkl@pengutronix.de, tglx@linutronix.de,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	Tomi Valkeinen <tomi.valkeinen@ti.com>
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410185442-907-5-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Roger Quadros <rogerq@ti.com> [140908 07:11]:
> Display and DCAN drivers use syscon regmap to access some registers
> in the CORE control area. Add the syscon regmap node for this
> area.

Please repost the .dts changes in a separate series to avoid
conflicts.

Thanks,

Tony
