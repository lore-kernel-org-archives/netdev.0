From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Fri, 6 Jan 2012 17:55:13 -0800
Message-ID: <CA+55aFwbykuZ30i2qrdAbX=PzRC5jtOYuAk8s8j47OP7qDSM8g@mail.gmail.com>
References: <20120105.192833.760673635385506638.davem@davemloft.net>
 <CA+55aFyk6QJib8UCtK_gWzidr8Ti1utJgHg359fkq=+GY8hbnw@mail.gmail.com> <20120106.175028.1076280359661712542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57541 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759358Ab2AGBzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 20:55:35 -0500
In-Reply-To: <20120106.175028.1076280359661712542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2012 at 5:50 PM, David Miller <davem@davemloft.net> wrote:
>
> It replaces the crappy and hard to scale procfs socket listing junk,
> which doesn't even provide a way to filter requests.

No it doesn't.

Look, I have a *recent* distro (up-to-date F16) and the tool that is
mentioned (ss) doesn't actually use the new feature even when compiled
in.

So it doesn't "replace" anything, and buys normal people nothing at all.

Some day, maybe. Today? No. It's pure baggage. It shouldn't be "default y".

                               Linus
