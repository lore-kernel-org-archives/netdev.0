From: Greg Lindahl <greg@blekko.com>
Subject: Re: Treason uncloaked / Broken peer again
Date: Wed, 25 Feb 2009 22:30:45 -0800
Message-ID: <20090226063045.GD5501@bx9.net>
References: <20090221195829.GA14779@bx9.net> <Pine.LNX.4.64.0902212317410.20526@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rc.bx9.net ([64.13.160.15]:15398 "EHLO rc.bx9.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbZBZGar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 01:30:47 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902212317410.20526@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > A recent set of fiddling to our web crawler has resulted in crawled
> > Linux hosts frequently getting "Treason uncloaked" messages in their
> > dmesg. This has resulted in a modest amount of hate mail, surprisingly
> > little given that we crawl millions of hosts per day.

I'm continuing to get hate mail from all over the planet. Can anyone
recommend a webpage which I could point to that explains how harmless
this message can be? Google returns lots of scary warnings. I would
write one myself but the complainers are already dubious of me.

It seems that most complainers are running < 2.6.14, which had a
header prediction bug.

-- greg

