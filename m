From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] remove unused netlink NL_EMULATE_DEV code
Date: Fri, 18 Mar 2005 17:02:53 -0800
Message-ID: <20050319010253.GU5389@shell0.pdx.osdl.net>
References: <20050318233637.GS5389@shell0.pdx.osdl.net> <423B6DAE.9050803@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, davem@davemloft.net, netdev@oss.sgi.com
To: Max Krasnyansky <maxk@qualcomm.com>
Content-Disposition: inline
In-Reply-To: <423B6DAE.9050803@qualcomm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Max Krasnyansky (maxk@qualcomm.com) wrote:
> Why don't you kill Ethertap completely while you're at it. Ethertap needs 
> "Netlink device emulation"
> stuff. And this whole thing has been marked OBSOLETE for more than two 
> years now.
> Most projects seem to have switched to TUN/TAP long time ago.

I'd prefer that too.  What about the netlink_dev implementation itself?
Should it be marked obsolete?

thanks,
-chris
