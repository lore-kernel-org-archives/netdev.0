From: Hans-Peter Nilsson <hans-peter.nilsson@axis.com>
Subject: Re: linux-next: Tree for Oct 6
Date: Wed, 7 Oct 2015 15:31:51 +0200
Message-ID: <201510071331.t97DVpgB031864@ignucius.se.axis.com>
References: <20151007071046.GA21158@sudip-pc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: sfr@canb.auug.org.au, starvik@axis.com, jespern@axis.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com,
	jhs@mojatatu.com
To: sudipm.mukherjee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:52336 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbbJGNb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 09:31:58 -0400
In-reply-to: <20151007071046.GA21158@sudip-pc> (message from Sudip Mukherjee
	on Wed, 7 Oct 2015 09:10:46 +0200)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Date: Wed, 7 Oct 2015 09:10:46 +0200

> On Tue, Oct 06, 2015 at 04:46:53PM +0200, Hans-Peter Nilsson wrote:
> > Thanks for the heads-up, but any chance of a bug report as per
> > the instructions in the message?  It'll only speed up matters.
> I can try, but since I am using 4.6.3 version I doubt if I will get the
> required response (Happened with another arch).

Ow, way old.

> And this is the latest
> cris cross-compiler available in
> https://www.kernel.org/pub/tools/crosstool/files/bin/x86_64/

I have nothing to do with that.

> BTW, I did a bisect and if I revert 47bbbb30b433 ("sch_dsmark: improve memory locality")
> it again builds without any error.

Sorry, that's not really useful to me, neither are build logs.
What I need to proceed with fixing is preprocessed code and the
compiler options used, just as the bug-reporting instructions
say.  Now that I hear that you get the ICE with a really old gcc
version, I'm not inclined to look further, sorry.  Except, when
you mention the version I vaguely remember; it reminds me of a
bug fixed a long time ago.  Maybe it was PR53120?  Sorry, I
don't remember anything else useful.  Still, thanks; it'll
shorten the response time if other people tell me the same
thing.

brgds, H-P
