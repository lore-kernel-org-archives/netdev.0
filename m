From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] amd: Neaten and remove unnecessary OOM messages
Date: Wed, 25 Jun 2014 16:32:30 -0700 (PDT)
Message-ID: <20140625.163230.90574954824917070.davem@davemloft.net>
References: <1403550950.15811.15.camel@joe-AO725>
	<1403557507.20657.3.camel@joe-AO725>
	<1403559395.20657.8.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403559395.20657.8.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 23 Jun 2014 14:36:35 -0700

> Make the code flow a little better for 80 columns.
> 
> Use a consistent style for the RX and TX rings allocation.
> Use BIT macro.
> Use a temporary unsiged int entries for (1<<size).
> Remove the OOM messages as they duplicate the generic
> OOM and dump_stack() provided by the memory subsystem.
> Reflow allocs to 80 columns.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Please repost with adjusted subject prefix (amd --> pcnet32), thanks.
