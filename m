From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH 12/12] Drop bogus reference to tc-filters and add
	lartc.org link to manpage.
Date: Wed, 17 Oct 2007 18:50:50 +0200
Message-ID: <1192639850.18005.46.camel@localhost.localdomain>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
	 <1192179407-22461-2-git-send-email-andreas@fatal.se>
	 <1192179407-22461-3-git-send-email-andreas@fatal.se>
	 <1192179407-22461-4-git-send-email-andreas@fatal.se>
	 <1192179407-22461-5-git-send-email-andreas@fatal.se>
	 <1192179407-22461-6-git-send-email-andreas@fatal.se>
	 <1192179407-22461-7-git-send-email-andreas@fatal.se>
	 <1192179407-22461-8-git-send-email-andreas@fatal.se>
	 <1192179407-22461-9-git-send-email-andreas@fatal.se>
	 <1192179407-22461-10-git-send-email-andreas@fatal.se>
	 <1192179407-22461-11-git-send-email-andreas@fatal.se>
	 <1192179407-22461-12-git-send-email-andreas@fatal.se>
	 <20071012145043.37e2317f@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:33062 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512AbXJQQvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 12:51:16 -0400
In-Reply-To: <20071012145043.37e2317f@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On fre, 2007-10-12 at 14:50 -0700, Stephen Hemminger wrote:
> Applied 1,2,5,6,7,8,9,11,12 and provided alternative
> patch for 3.
> 

Did I miss something, am I to cross-eyed to see they are there, or did
you miss to apply some of the patches?

This is my comparison of the submissions I made against what shows up at
http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=shortlog


1 - MISSING (fixes multiple typos, From: Alexander Wirt)
2 - MISSING (add ro src and ru prio param to help text, From: Alexander Wirt)
3 - dropped (alternative patch used)
4 - dropped (netbug script removed)
5 - MISSING (o_key vs i_key, From: Herbert Xu)
6 - applied and REVERTED (Remove reference to tc-filters, From: Andreas Barth)
7 - MISSING (tc -batch broken lines and comments fix, From: Andreas Henriksson)
8 - applied
9 - applied
10 - dropped (broken mpath support removed)
11 - applied
12 - applied

... and the 2 additional patches where applied.


The ones I have doubt about are: 1, 2, 5, 6, 7.
Could you please double-check and tell me what happened to them?


-- 
Regards,
Andreas Henriksson

