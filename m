From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: Add Atari EtherNAT support
Date: Thu, 15 Jan 2015 19:33:14 -0500 (EST)
Message-ID: <20150115.193314.72275448543984078.davem@davemloft.net>
References: <1421327175-7613-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, schmitzmic@gmail.com,
	schmitz@debian.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1421327175-7613-1-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 15 Jan 2015 14:06:15 +0100

> From: Michael Schmitz <schmitzmic@gmail.com>
> 
> Add Atari specific code to the smc91x Ethernet driver. This code is used
> on the EtherNAT adapter card for the Atari Falcon extension port.
> 
> Signed-off-by: Michael Schmitz <schmitz@debian.org>
> Tested-by: Christian Steigies <cts@debian.org>
> [geert: Sort Kconfig entries, split in hard and soft dependencies]
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied to net-next, thanks.
