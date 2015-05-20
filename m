From: David Miller <davem@davemloft.net>
Subject: Re: iptables: ensure number of counters is >0 in do_replace()
Date: Tue, 19 May 2015 20:20:43 -0400 (EDT)
Message-ID: <20150519.202043.366626459892331717.davem@davemloft.net>
References: <20150519231120.GA1761@codemonkey.org.uk>
	<20150519231950.GA30845@breakpoint.cc>
	<20150519234252.GA17307@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150519234252.GA17307@codemonkey.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@codemonkey.org.uk>
Date: Tue, 19 May 2015 19:42:52 -0400

> What's the preferred format, 8 separate patches, or 1 all-in-one
> diff for all instances of this bug ?

Personally, I think you could do this in one patch.
