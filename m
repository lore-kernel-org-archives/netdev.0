From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] ircomm - set owner get rid of MOD_INC/MOD_DEC
Date: Mon, 18 Aug 2003 11:40:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818184059.GA6457@bougret.hpl.hp.com>
References: <20030818111746.34b9e52b.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030818111746.34b9e52b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2003 at 11:17:46AM -0700, Stephen Hemminger wrote:
> Ircomm in 2.6.0-test3 can just set the owner field in the tty structure
> like other drivers, and not mess with MOD_INC/MOD_DEC.

	You missed a couple of comments. I sent the more complete
version of the exact same patch a few weeks ago to Jeff Garzik, you
may want to check with Jeff what the status on this.
	Of course, I would prefer the "more complete" version to go
in.

	By the way, because of Jeff's turnaround, we are going to have
this problem a lot. All my pending IrDA patches are listed on my web
page, you may want to check it :
	http://www.hpl.hp.com/personal/Jean_Tourrilhes/IrDA/IrDA.html

	Thanks for the good work !

	Jean

P.S. : Did you manage to set-up the crossover serial cable ?
