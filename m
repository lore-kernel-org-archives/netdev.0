From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] USAGI IPsec
Date: Sat, 12 Oct 2002 22:42:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021012.224212.56861427.davem@redhat.com>
References: <20021012111759.GA10104@outpost.ds9a.nl>
	<20021012.044137.42774593.davem@redhat.com>
	<20021012140644.0d403b2c.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: skraw@ithnet.com
In-Reply-To: <20021012140644.0d403b2c.skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephan von Krawczynski <skraw@ithnet.com>
   Date: Sat, 12 Oct 2002 14:06:44 +0200

   This was a 2.2.19 kernel with equal-cost-multipath enabled
   and large routing-tables enabled.

It doesn't surprise me that 2.2.x performs like crap under
any real load btw :-)  It has none of the 2.3.x scalability
and threading work.
