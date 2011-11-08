From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sunhme: Allow usage on SBI based SBus systems
Date: Tue, 08 Nov 2011 14:01:53 -0500 (EST)
Message-ID: <20111108.140153.2073990811396907800.davem@davemloft.net>
References: <Pine.LNX.4.64.1111072217540.4069@oizys.tordivel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: oftedal@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1111072217540.4069@oizys.tordivel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kjetil Oftedal <oftedal@gmail.com>
Date: Mon, 7 Nov 2011 22:47:53 +0100 (CET)

> To prevent the SBus driver for Sun Happy Meal cards from being loaded for 
> PCI cards utilizing the same chipset, a filter was added to the probe 
> function in commit 0b492fce3d72d982a7981905f85484a1e1ba7fde.
> 
> The filter was implemented by checking the name of the parent node in 
> the OF tree. This patch extends this filter, so that the driver will 
> load on SBus systems that are based upon SBI SBus Bridges.
> 
> Signed-off-by: Kjetil Oftedal <oftedal@gmail.com>

Applied, thanks.
