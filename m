From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after final merge (net tree)
Date: Thu, 18 Feb 2010 22:53:49 -0800 (PST)
Message-ID: <20100218.225349.258488745.davem@davemloft.net>
References: <20100219173713.e3f9f386.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kristoffer@gaisler.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100219173713.e3f9f386.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 19 Feb 2010 17:37:13 +1100

> I assume that this driver was written and tested only on Sparc ... maybe
> it should depend on SPARC?
> 
> I have reverted that commit for today.

I'll take a look at what it really depends upon.

Thanks.
