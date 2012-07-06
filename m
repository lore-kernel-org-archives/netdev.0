From: Fengguang Wu <wfg@linux.intel.com>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 6 Jul 2012 16:34:29 +0800
Message-ID: <20120706083429.GA28983@localhost>
References: <20120705.234229.526162609862035833.davem@davemloft.net>
 <20120706073745.GA28197@localhost>
 <20120706075245.GA28521@localhost>
 <20120706.012921.1688197243231281609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24605 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337Ab2GFJ0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 05:26:01 -0400
Content-Disposition: inline
In-Reply-To: <20120706.012921.1688197243231281609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 06, 2012 at 01:29:21AM -0700, David Miller wrote:
> From: Fengguang Wu <wfg@linux.intel.com>
> Date: Fri, 6 Jul 2012 15:52:45 +0800
> 
> > On Fri, Jul 06, 2012 at 03:37:45PM +0800, Fengguang Wu wrote:
> >> Hi David,
> >> 
> >> > Fengguang Wu can I ask you politely not to quote the quilty patch in
> >> > it's entirety when reporting bugs?  That screws up my workflow because
> >> > that patch goes then gets installed as a new patch in patchwork and I
> >> > have to therefore tick it off every time you report a bug.
> >> 
> >> Sorry for that!  Is it fine to _attach_ the referenced patch, or just
> >> a raw diff?  Or, the commit SHA and subject are all you want to see?
> > 
> > I used git-format-patch which makes a formal patch. How about git-show?
> > The output will be less like a formal patch, for example:
> 
> No patch, in any format.
> 
> It's completely pointless to attach the diff, anyone can use the
> commit log message and SHA ID to fetch the patch if they want.

OK!

> It's redundancy therefore also makes it a huge waste of bandwidth.  I
> have no idea why you provide it in the first place.

I find it very convenient on myself for confirming the error/warning..

Thanks,
Fengguang
