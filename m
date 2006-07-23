From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: wireless-2.6 git repos broken
Date: Sun, 23 Jul 2006 11:13:52 -0500
Message-ID: <44C3A040.8000206@lwfinger.net>
References: <200607231722.39504.mb@bu3sch.de> <44C39B4F.9020002@gentoo.org> <44C39CCD.70702@lwfinger.net> <200607231807.27556.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Junio C Hamano <junkio@cox.net>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:7579 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751248AbWGWQOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 12:14:02 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607231807.27556.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Sunday 23 July 2006 17:59, Larry Finger wrote:
>>> Do you have the same problem on other git trees?
>>> I saw some people running into this error when cloning Linus' 
>>> linux-2.6.git. I couldn't reproduce it, using exactly the same git version.
>> I had the same error when pulling from Linus's tree. It was fixed with a 'git fsck-objects --full' 
>> command.
> 
> Uhm, that tells me the git tree on kernel.org is broken
> and John has to run this command, right?
> 
I think so.

Larry

