From: "David S. Miller" <davem@davemloft.net>
Subject: Re: af_packet.c bug?
Date: Mon, 28 Mar 2005 12:33:37 -0800
Message-ID: <20050328123337.6dbd4870.davem@davemloft.net>
References: <424858D4.8060604@candelatech.com>
	<20050328195557.GF3086@postel.suug.ch>
	<4248642E.40304@candelatech.com>
	<20050328121806.3208ac40.davem@davemloft.net>
	<42486961.9060609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42486961.9060609@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005 12:30:25 -0800
Ben Greear <greearb@candelatech.com> wrote:

> It would be nice to have a list of all of these sockets so we could get info
> on them similar to the 'netstat -an' output anyway...

/proc/net/packet is insufficient?
