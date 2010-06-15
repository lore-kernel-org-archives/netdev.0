From: Joe Perches <joe@perches.com>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 10:42:30 -0700
Message-ID: <1276623750.1586.81.camel@Joe-Laptop.home>
References: <1276580526.30434.330.camel@edumazet-laptop>
	 <20100614.225910.104075511.davem@davemloft.net>
	 <1276618932.1586.64.camel@Joe-Laptop.home>
	 <20100615.102305.28825768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1138 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004Ab0FORmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 13:42:32 -0400
In-Reply-To: <20100615.102305.28825768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-15 at 10:23 -0700, David Miller wrote:
> > What do you think is missing from the gitk file viewer?
> I don't use the gitk file viewer, I use "git blame".

I've never thought git blame was very good for changelog
tracking as it's a static representation at a particular
commit/rev.

> Requiring a GUI to get at the information I need is unacceptable.  I
> often work remotely and use text consoles for everything, even email
> and web browsing.

You want an interactive, text-based (curses?) git-blame style
file viewer with push/pop git rev-list capabilities?

Something akin to emacs egit?


