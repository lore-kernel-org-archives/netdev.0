From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 2 Jan 2007 21:04:17 -0500
Message-ID: <20070103020411.GA5661@tuxdriver.com>
References: <20061221030340.GA9277@tuxdriver.com> <20061221030503.GB9277@tuxdriver.com> <4591969A.1040403@garzik.org> <20061228001051.GA3443@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, uberlord@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4881 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbXACCc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 21:32:57 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20061228001051.GA3443@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 27, 2006 at 07:10:57PM -0500, John W. Linville wrote:
> On Tue, Dec 26, 2006 at 04:39:38PM -0500, Jeff Garzik wrote:
> > John W. Linville wrote:
> > >The following changes since commit 
> > >0c234ae655a45ac3ee53a25b2e56e9bb6c27d71d:
> > >  Ulrich Kunitz (1):
> > >        ieee80211softmac: Fix mutex_lock at exit of 
> > >        ieee80211_softmac_get_genie
> > >
> > >are found in the git repository at:
> > >
> > >  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git 
> > >  upstream
> > >
> > >Roy Marples (1):
> > >      prism54: set carrier flags correctly
> > 
> > Why is this not #upstream-fixes material?  What's the impact?
> 
> Just being cautious, really.  I have no objection if you want to pull
> it as a fix.

After further review...

Jeff, it looks like you have not pulled this one so far.  Based on
the commentary from Roger While [1], lets hold-off on this one.

Roy, please consider refactoring your patch based on Roger's comments.

Thanks,

John

[1] http://marc.10east.com/?l=linux-netdev&m=116740017623597&w=2

-- 
John W. Linville
linville@tuxdriver.com
