From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: sja1000_isa: convert to platform driver to
 support x86_64 systems
Date: Tue, 29 Nov 2011 18:36:13 -0500 (EST)
Message-ID: <20111129.183613.828663777011052539.davem@davemloft.net>
References: <4ECE153E.7090408@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lambert.willy@gmail.com
To: wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ECE153E.7090408@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 24 Nov 2011 10:58:22 +0100

> This driver is currently not supported on x86_64 systems because the
> "isa_driver" interface is used (CONFIG_ISA=y). To overcome this
> limitation, the driver is converted to a platform driver, similar to
> the serial 8250 driver.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied to net-next.
