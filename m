From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: ipv4: Standardize prefixes for message
 logging
Date: Mon, 19 Mar 2012 14:00:04 -0700
Message-ID: <1332190804.6525.12.camel@joe2Laptop>
References: <1331526971.13200.9.camel@joe2Laptop>
	 <20120311.234846.455580505379366792.davem@davemloft.net>
	 <1331571812.13200.23.camel@joe2Laptop>
	 <20120312.170558.584205292599435892.davem@davemloft.net>
	 <1331598952.13200.43.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331598952.13200.43.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-12 at 17:35 -0700, Joe Perches wrote:
> On Mon, 2012-03-12 at 17:05 -0700, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Mon, 12 Mar 2012 10:03:32 -0700
> > > Add #define pr_fmt(fmt) as appropriate.
> > > Add "IPv4: ", "TCP: ", and "IPsec: " to appropriate files.
> > > Standardize on "UDPLite: " for appropriate uses.
> > > Some prefixes were previously "UDPLITE: " and "UDP-Lite: ".
> []
> > Looks good, and applied,
> OK.  I'll submit a similar change for net/ipv6 in awhile.

Would you still take a similar IPv6: prefix
change for net-next or should I wait until
the next release cycle?
