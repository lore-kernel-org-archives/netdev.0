From: Pekka Savola <pekkas@netcore.fi>
Subject: ttcp (maintenance) future?
Date: Tue, 18 Mar 2008 21:13:11 +0200 (EET)
Message-ID: <alpine.LRH.1.00.0803182112590.1563@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:38158 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763569AbYCSUHN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2008 16:07:13 -0400
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id m2IJDBxX002102
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 21:13:11 +0200
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id m2IJDBMf002099
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 21:13:11 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've maintaned somewhat updated version of ttcp [1] since 2001 but have not 
bothered to increment a version number or properly distribute it, CVS version 
the changes, etc.

Having one place with versioning, at least annual releases, etc. would likely 
be beneficial so all the distributions (both Linux and e.g. BSDs) that ship it 
could pick up and benefit from the changes collected in one place.

Some questions to the community as a whole:

- Has this already been done (in some other, modified ttcp version)?

- Is this worth doing given that there are other ttcp forks such as
   nuttcp and nttcp (these add major new features which I believe is
   not in scope for the original ttcp)?

- Are there major ttcp modifications that a future maintainer should
   be aware of?

- Would someone be willing to step up and take the maintenance to the
   next step?  (If not, I'll have to consider whether I can do it
   myself.)

[1]
http://netcore.fi/pekkas/linux/ipv6/ttcp.c

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
