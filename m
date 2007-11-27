From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 15:12:51 +0100
Message-ID: <20071127141251.GA4291@ff.dom.local>
References: <759014.71791.qm@web51409.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:57780 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756429AbXK0OIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 09:08:16 -0500
Content-Disposition: inline
In-Reply-To: <759014.71791.qm@web51409.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 05:00:55AM -0800, Joerg Pommnitz wrote:
...
> The OLSR traffic was obviously generated locally (not forwarded).
> You claim, that the TOS value for locally generated traffic does
> not influence its priority?

I wouldn't say "I claim": I've found something like this 'long time
ago' (enough to forget), and didn't need this information since
then. Now, I see you have 'nearby' problem, so it's only a hint.
After your first message I think you should be able to check this
by yourself. But, if there are any problems with this, you find my
idea wrong or not valid anymore, I'm interested in knowing about
this.

Cheers,
Jarek P.
