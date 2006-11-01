From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: ipw3945?
Date: Tue, 31 Oct 2006 17:40:49 -0800
Message-ID: <4547FB21.3050509@linux.intel.com>
References: <45464A2C.5090402@feuerpokemon.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30052 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1945988AbWKABk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 20:40:28 -0500
To: dragoran <dragoran@feuerpokemon.de>
In-Reply-To: <45464A2C.5090402@feuerpokemon.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dragoran wrote:
...
> It seems that the development of the driver has stopped since july,
> maybe because it never will get merged and intel decided to stop working
> on it?

Development hasn't stopped, I'm just a slacker ;).  I was away from work
for a while, and on return I was sucked into various issues that have
now (hopefully) all been resolved (or routed to /dev/null).

We have several patches that have backed up in our bug database
(http://bughost.org/cover/ and click on 'tested patches') that I'll be
pushing to our GIT tree as well as releasing a new snapshot to SF.

We've also been working on some new code internally we're putting
through some testing before we push out.  Expect some good things in the
coming weeks.

> If this is true it could mean that feature intel wlan chips will end up
> with no linux drivers :(

We do what we can internally to ensure that is never the case.

James
