From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] phy: micrel: Fix finding PHY properties in MAC
 node for KSZ9031.
Date: Tue, 22 Dec 2015 17:14:44 -0500 (EST)
Message-ID: <20151222.171444.1073714139867888727.davem@davemloft.net>
References: <1450781920-26912-1-git-send-email-henri.roosen@ginzinger.com>
	<20151222110634.GC2373@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: henri.roosen@ginzinger.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151222110634.GC2373@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 22 Dec 2015 12:06:34 +0100

> On Tue, Dec 22, 2015 at 11:58:40AM +0100, Henri Roosen wrote:
>> Commit 651df2183543 ("phy: micrel: Fix finding PHY properties in MAC
>>  node.") only fixes finding PHY properties in MAC node for KSZ9021. This
>> commit applies the same fix for KSZ9031.
>> 
>> Signed-off-by: Henri Roosen <henri.roosen@ginzinger.com>
> 
> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
> 
> Acked-by: Andrew Lunn <andrew@lunn.ch>

This does not apply cleanly to any of my trees.
