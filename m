From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] neighbour cache statistics like rt_stat
Date: Mon, 27 Sep 2004 22:17:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927221705.53a629d1.davem@davemloft.net>
References: <20040927093613.GH3236@sunbeam.de.gnumonks.org>
	<20040927162334.GV3236@sunbeam.de.gnumonks.org>
	<20040927122136.7016b2c1.davem@davemloft.net>
	<20040927222055.GD3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040927222055.GD3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 00:20:55 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> On Mon, Sep 27, 2004 at 12:21:36PM -0700, David S. Miller wrote:
> 
> > 1) Please update the patch since I replaced "diff4" with
> >    a patch simply removing the INCOMPLETE checks from neigh_forced_gc()
> > 
> > 2) I'd recommend using unsigned long for all the statistics.
> 
> both updated in attached version.

Applied, thanks Harald.
