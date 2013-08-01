From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 00/13] update tile network drivers
Date: Thu, 01 Aug 2013 14:42:31 -0700 (PDT)
Message-ID: <20130801.144231.1629813856606655018.davem@davemloft.net>
References: <20130731.122534.774117327230299927.davem@redhat.com>
	<201308011545.r71Fjbco017295@farm-0002.internal.tilera.com>
	<cover.1375385119.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, eric.dumazet@gmail.com
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375385119.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 1 Aug 2013 15:25:19 -0400

> This is v3 of the patch series to update the Tilera network drivers.
> 
> From the v1 00/13 cover letter: "This patch series contains changes made
> to the Tilera on-chip network drivers for both the 64-bit tilegx and
> 32-bit tilepro architectures.  The changes involve a number of bug fixes,
> support for the multiple mPIPEs on the new Gx72 chip, support for jumbo
> frames, TSO for IPv6, GRO, PTP support, and statistics improvements."
> 
> David has already applied the v2 patch for what was patch 01/13 in the
> first series ("handle 64-bit statistics in tilepro network driver")
> so it is not included in this v3 series.

Series applied to net-next, thanks.
