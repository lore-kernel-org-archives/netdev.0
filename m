From: "David S. Miller" <davem@davemloft.net>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 15:13:44 -0800
Message-ID: <20050113151344.32f7833f.davem@davemloft.net>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501131328.34449.jeremy.guthrie@berbee.com>
	<20050113120050.0c734df5.davem@davemloft.net>
	<200501131443.34174.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501131443.34174.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Jan 2005 14:43:30 -0600
"Jeremy M. Guthrie" <jeremy.guthrie@berbee.com> wrote:

> I don't show that proc file being there.  I see it in 'iproute.c' but not in 
> proc.

Sorry, my bad, it's

/proc/sys/net/ipv4/route/secret_interval
