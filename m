From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (0/16) intro to IRDA patches for 2.6.0-test6
Date: Tue, 30 Sep 2003 16:00:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930230049.GA22339@bougret.hpl.hp.com>
References: <20030930152530.1e279c29.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        irda-users@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030930152530.1e279c29.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2003 at 03:25:30PM -0700, Stephen Hemminger wrote:
> These patches are a replacement for the moderate one chunk I sent out yesterday.
> They continue in the same vein of revising how IRDA devices are allocated.
> The new thing is the introduction of alloc_irdadev and changing over the places
> I used alloc_netdev to that.
> 
> Mostly they are trivial, but smsc-ircc2 got changed to get rid of check_region
> usage as well.
> 
> David, please apply after Jean gives his approval.

	The self destruct patch is absolutely needed, and I like very
much the alloc_irdadev work.
	Please go ahead, I'll test them in parallel.
	Thanks !

	Jean
