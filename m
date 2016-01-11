From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: bfin_mac: Use phy_find_first() instead of
 open-coding it
Date: Mon, 11 Jan 2016 00:00:59 -0500 (EST)
Message-ID: <20160111.000059.2259197091861211706.davem@davemloft.net>
References: <1452487429-6197-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452487429-6197-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun, 10 Jan 2016 20:43:49 -0800

> Use phy_find_first() to find the first phy device instead of
> open-coding it.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
