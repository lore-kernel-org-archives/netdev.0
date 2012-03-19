From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: Standardize prefixes for message
 logging
Date: Mon, 19 Mar 2012 17:03:49 -0400 (EDT)
Message-ID: <20120319.170349.957038489849471796.davem@davemloft.net>
References: <20120312.170558.584205292599435892.davem@davemloft.net>
	<1331598952.13200.43.camel@joe2Laptop>
	<1332190804.6525.12.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332190804.6525.12.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 19 Mar 2012 14:00:04 -0700

> On Mon, 2012-03-12 at 17:35 -0700, Joe Perches wrote:
>> On Mon, 2012-03-12 at 17:05 -0700, David Miller wrote:
>> > From: Joe Perches <joe@perches.com>
>> > Date: Mon, 12 Mar 2012 10:03:32 -0700
>> > > Add #define pr_fmt(fmt) as appropriate.
>> > > Add "IPv4: ", "TCP: ", and "IPsec: " to appropriate files.
>> > > Standardize on "UDPLite: " for appropriate uses.
>> > > Some prefixes were previously "UDPLITE: " and "UDP-Lite: ".
>> []
>> > Looks good, and applied,
>> OK.  I'll submit a similar change for net/ipv6 in awhile.
> 
> Would you still take a similar IPv6: prefix
> change for net-next or should I wait until
> the next release cycle?

Sure why not, everyone else is being a complete idiot and submitting
all of their shit at the merge window openning.

I am backlogged every single time the merge window opens up, why do
you people wait until the last possible minute to submit things?  Are
you all too selfish or too stupid to care?

Every single one of you know it's coming, you see several -rc releases
go out.

The merge window isn't a trigger to "get it done and submitted right
now."

Instead, it really means "too late."
