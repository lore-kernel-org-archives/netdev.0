From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Mon, 27 Sep 2004 13:53:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16727.65341.747293.986870@robur.slu.se>
References: <Pine.LNX.4.58.0409252249150.1175@u.domain.uli>
	<20040925201425.16fbcb6c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040925201425.16fbcb6c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



I'll guess struct fib_alias should not be defined in fib_hash.c to 
support pluggable lookup algorithms.

Cheers.
						--ro
