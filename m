From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 19:18:30 -0400
Message-ID: <20070917231830.GG9282@tuxdriver.com>
References: <20070916.202258.03371690.davem@davemloft.net> <20070917.141826.70218261.davem@davemloft.net> <20070917144037.100b3fc1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4646 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753739AbXIQXld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 19:41:33 -0400
Content-Disposition: inline
In-Reply-To: <20070917144037.100b3fc1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 17, 2007 at 02:40:37PM -0700, Andrew Morton wrote:
> On Mon, 17 Sep 2007 14:18:26 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:

> > I guess a lot of this could be avoided if I simply merge in whatever
> > external stuff you're sucking in.

> plus boatloads of stuff in wireless.
> 
> >  I imagine this is just one of
> > Linville's trees (I'm surprised that hasn't been sent to me frankly)
> > and some specific new drivers you're merging in.

The stuff in wireless-dev is a collection of drivers (some of which
probably should be merged now) and some mac80211 gorp that is not
yet merge-worthy.  Trust me, I'm trying to get as many items out of
it as possible.

> Yeah, git-net versus git-wireless isn't pretty.  The huge amount of pending
> wireless stuff has been a bit of a nuisance for some months.  But it's
> probably a bigger nuisance for John ;)

Yeah...<sigh>...yeah...<sigh>...yeah... :-(

But as hch would surely point-out, it is my own laziness at fault...and
driver authors who tremble in fear when I mention merging their
drivers upstream...but, I digress... :-)

I just (minutes ago) finished the mop-up of the patch mess which
had accumulated on me during my KS-related travel and the subsequent
period of catching-up.  (I'm sure I still missed something or botched
something).  I think I can get an -mm suitable patch together within
the next few hours.

John

P.S.  Andrew, I'll send you a link to a new git-wireless.patch --
I'm sure you don't want a complicated git invocation...  Until then,
I don't think you should try pulling wireless-dev...
-- 
John W. Linville
linville@tuxdriver.com
