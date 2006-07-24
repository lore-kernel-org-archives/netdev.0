From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: wireless-2.6 git repos broken
Date: Mon, 24 Jul 2006 12:14:47 -0400
Message-ID: <20060724161441.GA17005@tuxdriver.com>
References: <200607231722.39504.mb@bu3sch.de> <44C39B4F.9020002@gentoo.org> <44C39CCD.70702@lwfinger.net> <200607231807.27556.mb@bu3sch.de> <44C3A040.8000206@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Junio C Hamano <junkio@cox.net>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:17932 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751321AbWGXQPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 12:15:14 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <44C3A040.8000206@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 23, 2006 at 11:13:52AM -0500, Larry Finger wrote:
> Michael Buesch wrote:
> >On Sunday 23 July 2006 17:59, Larry Finger wrote:
> >>>Do you have the same problem on other git trees?
> >>>I saw some people running into this error when cloning Linus' 
> >>>linux-2.6.git. I couldn't reproduce it, using exactly the same git 
> >>>version.
> >>I had the same error when pulling from Linus's tree. It was fixed with a 
> >>'git fsck-objects --full' command.
> >
> >Uhm, that tells me the git tree on kernel.org is broken
> >and John has to run this command, right?
> >
> I think so.

Hmmm...well, I'll look into it.  FWIW, I cloned my git tree from
kernel.org onto my laptop while I was at OLS w/o any problems.

John
-- 
John W. Linville
linville@tuxdriver.com
