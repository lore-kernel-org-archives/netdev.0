From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arc_emac: write initial MAC address from devicetree to
 hw
Date: Tue, 22 Apr 2014 15:55:35 -0400 (EDT)
Message-ID: <20140422.155535.567731041058340048.davem@davemloft.net>
References: <1664530.jeK9vBIgft@typ>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexey.Brodkin@synopsys.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, heiko@sntech.de
To: max.schwarz@online.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1664530.jeK9vBIgft@typ>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Max Schwarz <max.schwarz@online.de>
Date: Fri, 18 Apr 2014 02:17:32 +0200

> The MAC address retrieved from dt was not actually written to the
> hardware. This meant proper communication was only possible after
> changing the MAC address.
> 
> Fix that by always writing the mac address during probing.
> 
> Signed-off-by: Max Schwarz <max.schwarz@online.de>

Applied, thank you.
