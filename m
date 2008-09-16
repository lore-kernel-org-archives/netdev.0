From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 11:18:08 +0200
Message-ID: <20080916091808.GA5938@alpha.franken.de>
References: <20080915204543.GD3994@havoc.gtf.org> <20080915.141442.139271313.davem@davemloft.net> <20080915215307.GA10340@alpha.franken.de> <20080915.151125.93659986.davem@davemloft.net> <20080916083934.GA7397@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753849AbYIPJaW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080916083934.GA7397@cs181140183.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 16, 2008 at 11:39:34AM +0300, Adrian Bunk wrote:
> On Mon, Sep 15, 2008 at 03:11:25PM -0700, David Miller wrote:
> > From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
> > Date: Mon, 15 Sep 2008 23:53:08 +0200
> > 
> > > On Mon, Sep 15, 2008 at 02:14:42PM -0700, David Miller wrote:
> > > > Most of those changes were complete and utter CRAP.
> > > 
> > > thank you, but the fix I've sent (de2104x) isn't crap. The bug breaks the 
> > > current debian-installer for Cobalt Qube1, when it tries to get an
> > > IP address via dhcp. 
> > 
> > And why is this bug that has been there for YEARS is appropriate
> > to fix outside of the merge window?
> >...
> 
> Such a fix is even suitable for -stable.

that was my feeling as well, but if David wants to see it in the next
merge window, it's his decision. It's not a important fix as the user
base is obviuosly pretty small. And I didn't know about that bug, when
the merge windows was open, so I couldn't fix it "in time".

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
