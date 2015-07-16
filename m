From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: fec: Ensure clocks are enabled while
 using mdio bus"
Date: Wed, 15 Jul 2015 17:32:13 -0700 (PDT)
Message-ID: <20150715.173213.1635174183408438052.davem@davemloft.net>
References: <1437005044-13433-1-git-send-email-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, B38611@freescale.com
To: clemens.gruber@pqgruber.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437005044-13433-1-git-send-email-clemens.gruber@pqgruber.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Clemens Gruber <clemens.gruber@pqgruber.com>
Date: Thu, 16 Jul 2015 02:04:04 +0200

> This reverts commit 6c3e921b18edca290099adfddde8a50236bf2d80.
> 
> The change did break ethernet support on the i.MX6Q and possibly also on
> other platforms: The PHY was not detected anymore and eth0 was not found.
> 
> Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>

This patch was already posted and in my queue (did you look?) and I applied
it earlier today.
