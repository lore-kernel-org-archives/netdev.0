From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Fri, 19 Jan 2007 03:42:14 -0500
Message-ID: <20070119084214.GG31580@tuxdriver.com>
References: <20070118154801.GB31580@tuxdriver.com> <20070118154906.GC31580@tuxdriver.com> <45B036B7.8080904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2648 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964983AbXASI4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 03:56:11 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <45B036B7.8080904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 18, 2007 at 10:10:47PM -0500, Jeff Garzik wrote:
> John W. Linville wrote:
> >The following changes since commit 
> >10764889c6355cbb335cf0578ce12427475d1a65:
> >  Larry Finger (1):
> >        bcm43xx: Fix failure to deliver PCI-E interrupts
> >
> >are found in the git repository at:
> >
> >  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git 
> >  upstream
> 
> ACK.  Open question of parentage, though:  I just rebased 
> netdev-2.6.git#upstream.  Is your wireless-2.6 affected by this rebase?
> 
> If not, I will go ahead and pull.

Right now it looks like this:

	Linus's tree -> my upstream-fixes branch -> my upstream branch

So, I think it should be fine for your you to pull.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
