From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: phy: Add support for SMSC LAN8740 PHY
Date: Sat, 9 Jan 2016 17:00:15 +0100
Message-ID: <20160109160015.GC28813@lunn.ch>
References: <1452340461-5763-1-git-send-email-joshua.henderson@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Joshua Henderson <joshua.henderson@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452340461-5763-1-git-send-email-joshua.henderson@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 09, 2016 at 04:54:21AM -0700, Joshua Henderson wrote:
> LAN8740 has a different phy_id than LAN8710/LAN8720.
> 
> Signed-off-by: Joshua Henderson <joshua.henderson@microchip.com>
> ---
> Changes from v1:
> 	+ Remove explicitly setting .driver and apply against net-next

Thanks.

FYI: It is normal to put in the subject line if the patch is against
net or net-next.

    Andrew
