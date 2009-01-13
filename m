From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] NET: fix wrong English expression in comments
Date: Tue, 13 Jan 2009 09:04:02 +0000
Message-ID: <20090113090402.33d36725@lxorguk.ukuu.org.uk>
References: <496a3c51.09876e0a.03fe.7e80@mx.google.com>
	<496A9753.80802@cn.fujitsu.com>
	<1231724358.2674.13.camel@hashbaz.i.decadent.org.uk>
	<20090112.215320.197154233.davem@davemloft.net>
	<dc84318c0901122216s77bae26eo2dd36c4a0ee35177@mail.gmail.com>
	<496C53AF.3080901@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daolong Wang <ahlongxp@gmail.com>,
	David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	lizf@cn.fujitsu.com, qhfeng.kernel@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:41436 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755974AbZAMJEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 04:04:23 -0500
In-Reply-To: <496C53AF.3080901@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> "Don't add nothing," is not a colloquialism; it's just bad grammar.  The

It's a matter of dialect. For historical reasons English emerged from a
mix of languages and cultures (even within the UK). In some of the
originating languages and areas a double negative is emphatic in others
it negates the negation. Thus it is a bad idea when using globally - as
nobody is quite sure what you mean.

> As with spelling errors, corrections of this sort of thing are trivial
> and a waste of time.  I'm opposed to patches like that; they add no
> value and could be said to remove "character"; if that's important.

You may be so opposed, but they can be very problematic to non-English
speakers trying to use a dictionary or to understand if they are seeing a
typo or an unknown word: thus we do fix them. This is why we have the
trivial patch maintainer for such small fixes.

TRIVIAL PATCHES
P:	Jiri Kosina
M:	trivial@kernel.org
L:	linux-kernel@vger.kernel.org
T:	git kernel.org:/pub/scm/linux/kernel/git/jikos/trivial.git
S:	Maintained
