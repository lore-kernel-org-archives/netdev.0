From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 NET] Adjust RTATTR_MAX to IFLA_* changes
Date: Thu, 9 Sep 2004 10:53:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909105316.7a013c1b.davem@davemloft.net>
References: <20040909163131.GA18951@postel.suug.ch>
	<20040909103149.248a603e.davem@davemloft.net>
	<20040909174943.GA19155@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, eric.lemoine@gmail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040909174943.GA19155@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 19:49:43 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * David S. Miller <20040909103149.248a603e.davem@davemloft.net> 2004-09-09 10:31
> > I just checked iproute2 sources and it does not reference
> > this thing, so probably best to kill it off, like so.
> 
> This is even better, works fine for me.

Great, this is what I'll push upstream.
