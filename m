From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Thu, 23 Sep 2004 22:47:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923224723.743da8c8.davem@davemloft.net>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
	<20040921203118.734a0a7e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040921203118.734a0a7e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004 20:31:18 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> I'll work on the set of patches implementing the above tomorrow
> and will send it to the list for review and commentary.

Ok, coming in followup emails.

The hardest was abstracting the generic neigh seq_file stuff
such that net/atm/clip.c could still fit in.
