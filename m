From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Fri, 06 Jan 2012 18:07:45 -0800 (PST)
Message-ID: <20120106.180745.694506225640408539.davem@davemloft.net>
References: <CA+55aFyk6QJib8UCtK_gWzidr8Ti1utJgHg359fkq=+GY8hbnw@mail.gmail.com>
	<20120106.175028.1076280359661712542.davem@davemloft.net>
	<CA+55aFwbykuZ30i2qrdAbX=PzRC5jtOYuAk8s8j47OP7qDSM8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759355Ab2AGCHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 21:07:47 -0500
In-Reply-To: <CA+55aFwbykuZ30i2qrdAbX=PzRC5jtOYuAk8s8j47OP7qDSM8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 6 Jan 2012 17:55:13 -0800

> Look, I have a *recent* distro (up-to-date F16) and the tool that is
> mentioned (ss) doesn't actually use the new feature even when compiled
> in.
> 
> So it doesn't "replace" anything, and buys normal people nothing at all.
> 
> Some day, maybe. Today? No. It's pure baggage. It shouldn't be "default y".

Oh I see.

Ok, we can take away those default Kconfig tags for the UDP and AF_UNIX
bits, no problem.
