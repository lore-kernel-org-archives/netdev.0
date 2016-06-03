From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 0/4] net-next: mediatek: improve phy support
Date: Fri, 03 Jun 2016 19:54:43 -0400 (EDT)
Message-ID: <20160603.195443.1166932614450106227.davem@davemloft.net>
References: <1464941829-38712-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, keyhaede@gmail.com, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464941829-38712-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Fri,  3 Jun 2016 10:17:05 +0200

> The current driver did not handle the RGMII delay modes and asymmetric flow
> control properly. The mii_bus is not freed properly. Also add support for
> fixed-phy allowing the driver to work on SoCs that have an internal gigabit
> switch.

Series applied, thanks John.
