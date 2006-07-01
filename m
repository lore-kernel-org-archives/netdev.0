From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6 (revised)
Date: Sat, 1 Jul 2006 11:00:28 -0400
Message-ID: <20060701150023.GA11459@tuxdriver.com>
References: <20060626212547.GE30706@tuxdriver.com> <20060628004838.GA15906@tuxdriver.com> <44A551C4.8090208@garzik.org> <20060630192658.GB4359@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2053 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751416AbWGAPAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2006 11:00:50 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20060630192658.GB4359@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 03:27:02PM -0400, John W. Linville wrote:
> On Fri, Jun 30, 2006 at 12:31:00PM -0400, Jeff Garzik wrote:
> 
> > >The following changes since commit 
> > >fcc18e83e1f6fd9fa6b333735bf0fcd530655511:
> > >  Malcolm Parsons:
> > >        uclinux: use PER_LINUX_32BIT in binfmt_flat
> > >
> > >are found in the git repository at:
> > >
> > >  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git 
> > >  upstream
> > 
> > nothing pulled?
> 
> Odd, the changes seem to be there...did you happen to pull zd1211rw
> first?  I based that branch off the HEAD of the upstream branch.

Just to be sure, I re-cloned the netdev-2.6 tree from kernel.org and
did pulls from the 'upstream' branch of wireless-2.6.  Everything
seemed to work as expected.

Do you have this commit?

	70a332b048e4d90635dfa47fc5d91cf87b5cc3a5

That is the latest one in my upstream branch.

John
-- 
John W. Linville
linville@tuxdriver.com
