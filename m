From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 23:23:28 -0400
Message-ID: <20070918032328.GB3875@tuxdriver.com>
References: <20070916.202258.03371690.davem@davemloft.net> <20070917.141826.70218261.davem@davemloft.net> <20070917144037.100b3fc1.akpm@linux-foundation.org> <20070917231830.GG9282@tuxdriver.com> <20070917164929.b53ac118.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4154 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406AbXIRNMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 09:12:23 -0400
Content-Disposition: inline
In-Reply-To: <20070917164929.b53ac118.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 17, 2007 at 04:49:29PM -0700, Andrew Morton wrote:
> On Mon, 17 Sep 2007 19:18:30 -0400
> "John W. Linville" <linville@tuxdriver.com> wrote:
> 
> > P.S.  Andrew, I'll send you a link to a new git-wireless.patch --
> > I'm sure you don't want a complicated git invocation...  Until then,
> > I don't think you should try pulling wireless-dev...
> 
> OK, thanks.
> 
> The stuff I have now does actually compile, although the chances of it
> actually working are epsilon.
> 
> So I'd rather not breathe on it today: I'l shove it out the door as-is
> with a big "this is probably broken" label on it.   I'll at least test
> ipw2200 before doing so.

Very reasonable -- I suspect even and "easy" -mm looks a lot like
the last few days have looked in my trees...

Anyway, I do have prepared an omnibus patch for you:

	http://www.kernel.org/pub/linux/kernel/people/linville/git-wireless-2007-09-17.patch

And FWIW, there is an 'mm-master' branch matching the usage to which
you are accustomed.  The git merge if you pull from that branch onto
net-2.6.24 is reasonably straight-forward and not too painful.  Still,
I'd recommend the patch at the URL above... :-)

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
