From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: faraday: Use phy_find_first()
 instead of open coding it
Date: Sun, 10 Jan 2016 22:06:05 -0500 (EST)
Message-ID: <20160110.220605.1377793956050429598.davem@davemloft.net>
References: <1452456272-1795-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452456272-1795-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun, 10 Jan 2016 12:04:32 -0800

> Use phy_find_first() to find the first phy device instead of
> open coding it.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
