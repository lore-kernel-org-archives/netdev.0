From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH 12/12] Drop bogus reference to tc-filters and add lartc.org link to manpage.
Date: Thu, 18 Oct 2007 10:13:13 +0200
Message-ID: <20071018081313.GA23682@scream.fatal.se>
References: <1192179407-22461-8-git-send-email-andreas@fatal.se> <1192179407-22461-9-git-send-email-andreas@fatal.se> <1192179407-22461-10-git-send-email-andreas@fatal.se> <1192179407-22461-11-git-send-email-andreas@fatal.se> <1192179407-22461-12-git-send-email-andreas@fatal.se> <20071012145043.37e2317f@freepuppy.rosehill> <1192639850.18005.46.camel@localhost.localdomain> <20071017100539.4877b4e4@freepuppy.rosehill> <1192643940.18005.60.camel@localhost.localdomain> <20071017110257.05991840@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:36641 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933415AbXJRI4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 04:56:01 -0400
Content-Disposition: inline
In-Reply-To: <20071017110257.05991840@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 11:02:57AM -0700, Stephen Hemminger wrote:
> 
> The tagging naming convention is messed up, but they are there:
> 
> $ git tag -l

I don't want to be a pain in the ass, but....

this is the list from my clone of 
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

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
ss050607
v2.6.19-061214
v2_6_10-050124
v2_6_10-050207
v2_6_10-050209
v2_6_11-050310
v2_6_11-050314
v2_6_11-050318
v2_6_11-050330
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


None of the tags are from (20)07.... 

And none of the tags at the gitweb have a tag from this year eigther.
http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=tags

Any chance you forgot to push the tags out to the public repo?
(Which you seem to have to do explicitly in git.)

--
Regards,
Andreas Henriksson
