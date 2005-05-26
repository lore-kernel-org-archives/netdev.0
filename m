From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Fri, 27 May 2005 00:26:56 +0200
Message-ID: <20050526222656.GD15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch> <20050526185526.GZ15391@postel.suug.ch> <20050526.151726.85409972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050526.151726.85409972.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050526.151726.85409972.davem@davemloft.net> 2005-05-26 15:17
> From: Thomas Graf <tgraf@suug.ch>
> Date: Thu, 26 May 2005 20:55:26 +0200
> 
> > This message is followed by 0..n messages carrying device
> > specific parameter sets. They all share the same value for
> > Although the ordering should be sufficient, NDTA_NAME can be
> 
> It seems a sentence is chopped off here mid-stream,
> please provide a fixed changelog so I can apply your
> patches.

Sorry, it's what happens if one gets interrupted in the middle
of writing a longer comment. ;-> Patch edited by hand but
it should still apply.
