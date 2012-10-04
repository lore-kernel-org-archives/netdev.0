From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 03 Oct 2012 21:47:50 -0400 (EDT)
Message-ID: <20121003.214750.2022020970468412510.davem@davemloft.net>
References: <20121004101833.019598b7e474c7b74e67ff20@canb.auug.org.au>
	<20121003.205053.1711360628623711137.davem@davemloft.net>
	<20121004110615.3fda3c25735284c776106d7d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, vipul@chelsio.com, jay@chelsio.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121004110615.3fda3c25735284c776106d7d@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 4 Oct 2012 11:06:15 +1000

> Actually, for me it is.  I have a script that does the "use yesterday's
> version" for me.  To fix (even a one liner) means bringing up an editor,
> commiting, creating the patch and then recommiting it (an implementation
> detail) and recording that I need to keep (automatically) applying the
> patch in case the maintainer doesn't react quickly.

Ok, fair enough.

I'll try to look into making x86 barf when a vmalloc.h include is
missing.
