From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] iproute2 updates
Date: Fri, 4 Mar 2005 08:42:56 -0800
Message-ID: <20050304084256.03550238@dxpl.pdx.osdl.net>
References: <20050304023520.GD31837@postel.suug.ch>
	<1109908154.1091.486.camel@jzny.localdomain>
	<20050304132653.GF31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050304132653.GF31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Mar 2005 14:26:53 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * jamal <1109908154.1091.486.camel@jzny.localdomain> 2005-03-03 22:49
> > On Thu, 2005-03-03 at 21:35, Thomas Graf wrote:
> > > Stephen,
> > > 
> > > You may pull the following changes from bk://tgr.bkbits.net/iproute2-tgr-fix
> > 
> > Other than NPROBES change, shouldnt the other changes be reflective of
> > whats in the kernel? This is the cost of keeping private headers. My
> > suggestions would be to let Steve on every major release to just sync
> > the header files.
> 
> Well, these are not exact copies, all the __KERNEL__ stuff is missing, a
> few CONFIG ifdefs must be cut out and a few extra bits such as u32 mark
> structures. I updated them because some of the structures were outdated.
> I do not care how it is done but it required an update.

I'll clone the 2.6.11 headers in the next update.
