From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH 12/12] Drop bogus reference to tc-filters and add
	lartc.org link to manpage.
Date: Wed, 17 Oct 2007 19:58:59 +0200
Message-ID: <1192643940.18005.60.camel@localhost.localdomain>
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
	 <1192639850.18005.46.camel@localhost.localdomain>
	 <20071017100539.4877b4e4@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:57777 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbXJQR70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 13:59:26 -0400
In-Reply-To: <20071017100539.4877b4e4@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On ons, 2007-10-17 at 10:05 -0700, Stephen Hemminger wrote:
> The missing ones are now applied to git, for next release which
> will either be a bug fix (if other problems show up) or wait
> until new features for 2.6.24 are included.
> 

Thank you!

We are currently working on importing the debian package to a git
repository. This includes learning git and suitable workflows for using
git with packages. Hopefully this will simplify sending patches upstream
in the future. While doing this I've noticed that some parts needs to be
split out in separate patches and that there are many more small things
that needs to be reviewed and sent upstream. Expect more patches coming
in the future (but don't hold your breath, it'll probably take a while
to gather all the needed free time).

Additionally I noticed that the last few releases hasn't been tagged, or
atleast the tags doesn't seem to be pushed out to the repo on
kernel.org. It would be nice for us if they where available, so please
put this on the wishlist. :)

I don't know if it's just me doing something wrong, but cloning from the
url with the symlink to your personal repository doesn't seem to work:
git://git.kernel.org/pub/network/iproute2/iproute2.git
Using this url works though:
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
(These are the urls from a previous mail you sent me.... Just wanted to
notify you in case something was broken with the symlink.)


Have a nice day.

-- 
Regards,
Andreas Henriksson

