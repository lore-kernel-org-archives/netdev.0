From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Fri, 8 Oct 2004 15:18:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008151839.01823e0c.akpm@osdl.org>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
	<20041007224422.1c1bea95@jack.colino.net>
	<20041007214505.GB31558@wotan.suse.de>
	<20041008090610.70d7e183@pirandello>
	<20041008220001.GE31237@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: colin@colino.net, ak@suse.de, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041008220001.GE31237@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall <mpm@selenic.com> wrote:
>
> > Concerning the hang, I see that Andrew has put my first patch, the one
> > checking for netif_carrier_ok(), in his tree.

I dropped it again, waiting for the dust to settle on this one.
