From: David Dillow <dave@thedillows.org>
Subject: Re: MAINTAINERS drivers/net cleanups?
Date: Mon, 19 Oct 2009 11:24:44 -0400
Message-ID: <1255965884.32011.13.camel@lap75545.ornl.gov>
References: <1255729936.2267.179.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute2.ornl.gov ([160.91.86.17]:42482 "EHLO emroute2.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756765AbZJSQAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 12:00:12 -0400
Received: from emroute2.ornl.gov ([127.0.0.1])
 by emroute2.ornl.gov (PMDF V6.4 #31561)
 with ESMTP id <0KRR00CI7PH9PK@emroute2.ornl.gov> for netdev@vger.kernel.org;
 Mon, 19 Oct 2009 11:24:45 -0400 (EDT)
In-reply-to: <1255729936.2267.179.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-16 at 14:52 -0700, Joe Perches wrote:
> Ben Hutchings suggested adding a facility to
> scripts/get_maintainer.pl to print the role of
> each maintainer.  I added a bit more to print
> statistics about the maintainers and "-by:" lines
> from each git commit as well.
[snip script]
> There are many people described as MAINTAINERS for
> these files that have not had a single sign-off or
> commit in git history.

Uhm, I think your script is broken, as I've patched typhoon this year.
I've also ACKed a few patches that have been sent to me, and tried to
watch the list for patches that weren't.

> Should these individuals be removed from MAINTAINERS
> and added to CREDITS if not already there?

I think you should try to contact the ones listed and see if they are
still actively watching for their drivers. I've not had to do a lot to
typhoon, as there is no new hardware coming out, and while I've sent in
several Acked-by's, not all of them have made it to the final commit.

Just because there are few patches from the person listed as maintainer
does not mean they are not keeping an eye on things.

> ------> drivers/net/typhoon.c
> David Dillow <dave@thedillows.org> (maintainer)
> 
> 3CR990 NETWORK DRIVER
> M: David Dillow <dave@thedillows.org>
> L: netdev@vger.kernel.org
> S: Maintained
> F: drivers/net/typhoon*

