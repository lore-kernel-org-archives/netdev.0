From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6171: Fix tag_protocol check
Date: Tue, 14 Oct 2014 16:23:52 -0400 (EDT)
Message-ID: <20141014.162352.791378690757940770.davem@davemloft.net>
References: <1413310864-16830-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413310864-16830-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 14 Oct 2014 11:21:04 -0700

> tag_protocol is now an enum, so drivers have to check against it.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
