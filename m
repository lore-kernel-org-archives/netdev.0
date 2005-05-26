From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
 statistics via rtnetlink
Date: Thu, 26 May 2005 15:17:26 -0700 (PDT)
Message-ID: <20050526.151726.85409972.davem@davemloft.net>
References: <20050526185306.GW15391@postel.suug.ch>
	<20050526185526.GZ15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050526185526.GZ15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 26 May 2005 20:55:26 +0200

> This message is followed by 0..n messages carrying device
> specific parameter sets. They all share the same value for
> Although the ordering should be sufficient, NDTA_NAME can be

It seems a sentence is chopped off here mid-stream,
please provide a fixed changelog so I can apply your
patches.

Thanks.
