From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: net tree build failure
Date: Mon, 11 Jan 2010 00:44:36 -0800 (PST)
Message-ID: <20100111.004436.217049216.davem@davemloft.net>
References: <20100111184205.8d53fe5b.Stephen@Rothwell.id.au>
	<20100111.000205.164473435.davem@davemloft.net>
	<1263197772.1907.44.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen@Rothwell.id.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	macro@linux-mips.org, hartleys@visionengravers.com
To: joe@perches.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1263197772.1907.44.camel@Joe-Laptop.home>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 11 Jan 2010 00:16:12 -0800

> Perhaps it'd be better to kill off the use of bitrev in
> lib/vsprintf as Maciej thinks it broken.
> 
> Maybe use something like this?
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Yeah that sounds like a better idea, I think I'll commit
this instead.

Thanks Joe!
