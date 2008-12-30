From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clean up of netif_rx_reschedule() changes in drivers
Date: Mon, 29 Dec 2008 18:19:08 -0800 (PST)
Message-ID: <20081229.181908.214463121.davem@davemloft.net>
References: <20081229102509.GA11111@linux.vnet.ibm.com>
	<20081229214144.43be8c1d.sfr@canb.auug.org.au>
	<20081229153757.GA2857@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, kamalesh@linux.vnet.ibm.com,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: nhorman@tuxdriver.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081229153757.GA2857@localhost.localdomain>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 29 Dec 2008 10:37:57 -0500

> On Mon, Dec 29, 2008 at 09:41:44PM +1100, Stephen Rothwell wrote:
> > Hi Kamalesh,
> > 
> > On Mon, 29 Dec 2008 15:55:29 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> > > greping through the sources for the changes missed out, we have
> > > 
> > 	.
> > 	.
> > > 
> > > Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
 ...
> Thanks guys, not sure how my patch missed that.  I did an allmodconfig build
> that passed successfully.  Thanks!

It's very simple, you're not building on powerpc or ARM :-)

> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks everyone.
