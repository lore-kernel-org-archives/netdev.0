From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Tue, 12 Feb 2013 16:15:38 -0500 (EST)
Message-ID: <20130212.161538.1899836892271837177.davem@davemloft.net>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 12 Feb 2013 01:22:17 +0530

> This patch series implements Dual EMAC mode implementation of CPSW
> which acts as two standalone EMAC by segregating the switch using VIDs
> and port VLAN
> 
> Mugunthan V N (3):
>   driver: net: ethernet: davinci_cpdma: add support for directed packet
>     and source port detection
>   driver: net: ethernet: cpsw: make cpts as pointer
>   driver: net: ethernet: cpsw: dual emac interface implementation

Series applied.
