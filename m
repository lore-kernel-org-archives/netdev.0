From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] mvneta: add FIXED_PHY dependency
Date: Mon, 9 Nov 2015 17:33:17 +0000
Message-ID: <20151109173316.GG8644@n2100.arm.linux.org.uk>
References: <4225885.EYXTHjRPmX@wuerfel>
 <20151109164232.GB3388@lunn.ch>
 <6910088.dNmooXDTJR@wuerfel>
 <20151109170849.GC3388@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151109170849.GC3388@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 09, 2015 at 06:08:49PM +0100, Andrew Lunn wrote:
> You use fixed-phy when the MAC is connected to a switch, not a phy. Or
> when the MAC is connected to an SFP module.

... hopefully not for much longer.  Once -rc1 is out, I'll sort out
posting my phylink and SFP module hotplug support as a RFC.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
