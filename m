From: "David S. Miller" <davem@davemloft.net>
Subject: Re: primary and secondary ip addresses
Date: Thu, 26 May 2005 14:58:07 -0700 (PDT)
Message-ID: <20050526.145807.130847153.davem@davemloft.net>
References: <20050412105442.GV7510@sunbeam.de.gnumonks.org>
	<200505081531.16106.hasso@estpak.ee>
	<20050526181118.GK13114@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hasso@estpak.ee, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
In-Reply-To: <20050526181118.GK13114@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Harald Welte <laforge@gnumonks.org>
Date: Thu, 26 May 2005 20:11:18 +0200

> David, would you consider applying that patch to mainline?  I think
> there was concensus on this solution, and it has now received some
> amount of testing by Hasso and me.

Since it retains the default behavior by default, this change
seems fine.  I've added it to my tree, thanks.
