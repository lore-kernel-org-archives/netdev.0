From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: request to queue "5d0f801 can: c_can: Fix RX message handling,
 handle lost message before EOB" for stable
Date: Mon, 25 Nov 2013 13:05:39 -0800
Message-ID: <20131125210539.GB24160@kroah.com>
References: <52928480.8010803@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Holger.Bechtold@gmx.net, Linux Netdev List <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52928480.8010803@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 24, 2013 at 11:58:08PM +0100, Marc Kleine-Budde wrote:
> Hello Greg,
> 
> can you please queue
> 
>     5d0f801 can: c_can: Fix RX message handling, handle lost message before EOB
> 
> for the stable trees.
> 
> This patch was part of a two-patches pull request to David's net/master
> tree, which was merged in:
> 
>     e9b51a1 Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-can/linux-can
> 
> One patch has already been queued, the other not.

It was part of my "to-apply" queue.  It's now applied, thanks.

greg k-h
