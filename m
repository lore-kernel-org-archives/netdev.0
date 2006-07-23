From: Michael Buesch <mb@bu3sch.de>
Subject: Re: wireless-2.6 git repos broken
Date: Sun, 23 Jul 2006 18:07:27 +0200
Message-ID: <200607231807.27556.mb@bu3sch.de>
References: <200607231722.39504.mb@bu3sch.de> <44C39B4F.9020002@gentoo.org> <44C39CCD.70702@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Junio C Hamano <junkio@cox.net>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:52194
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751226AbWGWQHq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 12:07:46 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44C39CCD.70702@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 23 July 2006 17:59, Larry Finger wrote:
> > Do you have the same problem on other git trees?
> > I saw some people running into this error when cloning Linus' 
> > linux-2.6.git. I couldn't reproduce it, using exactly the same git version.
> 
> I had the same error when pulling from Linus's tree. It was fixed with a 'git fsck-objects --full' 
> command.

Uhm, that tells me the git tree on kernel.org is broken
and John has to run this command, right?

-- 
Greetings Michael.
