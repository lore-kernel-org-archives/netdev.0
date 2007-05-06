From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Merging SSB upstream
Date: Sun, 6 May 2007 13:38:33 -0400
Message-ID: <20070506173833.GA4717@tuxdriver.com>
References: <200705060303.17594.mb@bu3sch.de> <20070506020051.GA30917@tuxdriver.com> <200705061144.27817.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Gary Zambrano <zambrano@broadcom.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, ralf@linux-mips.org,
	davej@codemonkey.org.uk, mtakahashi@kanno.co.jp
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3767 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754830AbXEFSC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2007 14:02:59 -0400
Content-Disposition: inline
In-Reply-To: <200705061144.27817.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 06, 2007 at 11:44:27AM +0200, Michael Buesch wrote:
> On Sunday 06 May 2007 04:00:51 John W. Linville wrote:

> > I had to remove 
> > the b44 ssb changes from fedora because a) users reported problems;
> 
> Which problems were that? The 2 compile issues?
> Trivial to fix if that's the only issue. ;)

I knew you would ask that... :-)

I don't think there was a bugzilla, but Dave Jones forwarded an email
to me from "MASAO TAKAHASHI" in late February.  Takahashi-san (forgive
me if I did that wrong) was complaining about tx timeouts after I
had added the full wireless-dev patchset to rawhide.  Removing the
b44 bits of the patch seemed to remove the problem.

That's all the info I have.  Perhaps Dave or Takahashi-san can add
to the description?

John
-- 
John W. Linville
linville@tuxdriver.com
