From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 12/12] Drop bogus reference to tc-filters and add
 lartc.org link to manpage.
Date: Wed, 17 Oct 2007 11:02:57 -0700
Message-ID: <20071017110257.05991840@freepuppy.rosehill>
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
	<1192643940.18005.60.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44005 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755989AbXJQSDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 14:03:48 -0400
In-Reply-To: <1192643940.18005.60.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Oct 2007 19:58:59 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> 
> On ons, 2007-10-17 at 10:05 -0700, Stephen Hemminger wrote:
> > The missing ones are now applied to git, for next release which
> > will either be a bug fix (if other problems show up) or wait
> > until new features for 2.6.24 are included.
> > 
> 
> Thank you!
> 
> We are currently working on importing the debian package to a git
> repository. This includes learning git and suitable workflows for using
> git with packages. Hopefully this will simplify sending patches upstream
> in the future. While doing this I've noticed that some parts needs to be
> split out in separate patches and that there are many more small things
> that needs to be reviewed and sent upstream. Expect more patches coming
> in the future (but don't hold your breath, it'll probably take a while
> to gather all the needed free time).
> 
> Additionally I noticed that the last few releases hasn't been tagged, or
> atleast the tags doesn't seem to be pushed out to the repo on
> kernel.org. It would be nice for us if they where available, so please
> put this on the wishlist. :)
> 
> I don't know if it's just me doing something wrong, but cloning from the
> url with the symlink to your personal repository doesn't seem to work:
> git://git.kernel.org/pub/network/iproute2/iproute2.git
> Using this url works though:
> git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
> (These are the urls from a previous mail you sent me.... Just wanted to
> notify you in case something was broken with the symlink.)
> 
> 
> Have a nice day.
> 

The tagging naming convention is messed up, but they are there:

$ git tag -l
ss050607
ss-050808
ss-050816
ss-050901
ss-050929
ss-051006
ss-051007
ss-051101
ss-051107
ss-060110
ss-060314
ss-060323
v2_6_10-050124
v2_6_10-050207
v2_6_10-050209
v2_6_11-050310
v2_6_11-050314
v2_6_11-050318
v2_6_11-050330
v2.6.19-061214
v2.6.23-071016
v2_6_7-040701
v2_6_7-040702
v2_6_7-ss040608
v2_6_8-040730
v2_6_8-040813-jamal
v2_6_8-040823
v2_6_8-ss040831
v2_6_9-041019
v2_6_9-jamal
v2_6_9-ss040831


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
