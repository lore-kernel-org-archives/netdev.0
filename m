From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 27 Dec 2006 19:10:57 -0500
Message-ID: <20061228001051.GA3443@tuxdriver.com>
References: <20061221030340.GA9277@tuxdriver.com> <20061221030503.GB9277@tuxdriver.com> <4591969A.1040403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3406 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964825AbWL1Acy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Dec 2006 19:32:54 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4591969A.1040403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 26, 2006 at 04:39:38PM -0500, Jeff Garzik wrote:
> John W. Linville wrote:
> >The following changes since commit 
> >0c234ae655a45ac3ee53a25b2e56e9bb6c27d71d:
> >  Ulrich Kunitz (1):
> >        ieee80211softmac: Fix mutex_lock at exit of 
> >        ieee80211_softmac_get_genie
> >
> >are found in the git repository at:
> >
> >  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git 
> >  upstream
> >
> >Roy Marples (1):
> >      prism54: set carrier flags correctly
> 
> Why is this not #upstream-fixes material?  What's the impact?

Just being cautious, really.  I have no objection if you want to pull
it as a fix.

John
-- 
John W. Linville
linville@tuxdriver.com
