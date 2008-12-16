From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] simnet: convert to net_device_ops
Date: Tue, 16 Dec 2008 01:56:02 -0800 (PST)
Message-ID: <20081216.015602.58187314.davem@davemloft.net>
References: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
	<20081209150827.GA8134@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081209150827.GA8134@x200.localdomain>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 9 Dec 2008 18:08:27 +0300

> On Tue, Dec 09, 2008 at 05:11:17PM +0300, Alexander Beregalov wrote:
> >   CC      arch/ia64/hp/sim/simeth.o
> > arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
> > arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no member named 'open'
> 
> [PATCH] simeth: convert to net_device_ops
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Now that the kconfig badness has been fixed, I've applied
this.

Thanks Alexey.
