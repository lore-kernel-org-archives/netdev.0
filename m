From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] net: phy: micrel: refactoring and KSZ8081/KSZ8091
 features
Date: Wed, 12 Nov 2014 13:56:07 -0500 (EST)
Message-ID: <20141112.135607.970670076636942787.davem@davemloft.net>
References: <1415732415-10363-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415732415-10363-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Tue, 11 Nov 2014 20:00:06 +0100

> This series cleans up and refactors parts of the micrel PHY driver, and
> adds support for broadcast-address-disable and led-mode configuration
> for KSZ8081 and KSZ8091 PHYs.
> 
> Specifically, this enables dual KSZ8081 setups (which are limited to
> using address 0 and 3).
> 
> A follow up series will add device-type abstraction which will allow for
> further refactoring and shared initialisation code.

Series applied, thanks Johan.
