From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ing_filter debug messages
Date: Fri, 31 Dec 2004 14:15:54 +0100
Message-ID: <20041231131553.GA7460@wiggy.net>
References: <20041230160643.GD24603@wiggy.net> <1104469666.1049.231.camel@jzny.localdomain> <20041231093827.GG24603@wiggy.net> <1104491510.1047.234.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104491510.1047.234.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously jamal wrote:
> Does attached patch fix it?

No change at all I'm afraid . While rebooting to the kernel with that
patch applied it got stuck in the shutdown sequence while repeating this
line:

unregister_netdevice: waiting for xs4all for become free, Usage count = 1

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
