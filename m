From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: appletalk/cops_probe BUG: soft lockup - CPU#1 stuck for 23s!
Date: Sun, 29 Jul 2012 21:01:42 +0800
Message-ID: <20120729130142.GA17155@localhost>
References: <20120729124022.GA16748@localhost>
 <20120729140003.6fa483d2@ultron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Joe Perches <joe@perches.com>,
	"kernel-janitors@vger.kernel..." <kernel-janitors@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120729140003.6fa483d2@ultron>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 29, 2012 at 02:00:03PM +0100, Alan Cox wrote:
> On Sun, 29 Jul 2012 20:40:22 +0800
> Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > Hi,
> > 
> > This is probably a rather old bug, triggered while doing randconfig
> > boot tests in kvm:
> 
> I'm not sure testing old devices with no safe probe method is useful in
> this context ?

Yeah. I'll just blacklist this driver in my builds.

Thanks,
Fengguang
