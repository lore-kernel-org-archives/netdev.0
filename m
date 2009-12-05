From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] drivers/net: Move && and || to end of
 previous line
Date: Sat, 05 Dec 2009 09:50:40 -0800
Message-ID: <1260035440.11126.50.camel@Joe-Laptop.home>
References: <1259001504.16503.79.camel@Joe-Laptop.home>
	 <20091123.104130.117837098.davem@davemloft.net>
	 <1259528449.29779.194.camel@Joe-Laptop.home>
	 <20091129.165557.84377714.davem@davemloft.net>
	 <1259863101.22783.63.camel@Joe-Laptop.home>  <4B190A29.5080905@myri.com>
	 <1259947271.22783.120.camel@Joe-Laptop.home>  <4B1A557D.4080707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756925AbZLERug@vger.kernel.org>
In-Reply-To: <4B1A557D.4080707@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-12-05 at 07:43 -0500, William Allen Simpson wrote:
> Joe Perches wrote:
> > On Fri, 2009-12-04 at 14:10 +0100, Brice Goglin wrote:
> >> Joe Perches wrote:
> >>> Only files where David Miller is the primary git-signer.
> >>> wireless, wimax, ixgbe, etc are not modified.
> >> What's the point? Having them at the beginning of the next line is
> >> easier to read from my point of view.
> > It's just a stupid consistency thing.
> Joe *agrees* that
> having them on the beginning of the line is preferred.

This is not true.

I prefer code that I write for myself to
use leading continuation tests.

For the Linux code, as should be obvious
from the patches I submit, I prefer to
have adherence to one predominant majority
style.  I don't much care what form that
style actually takes.

> Thousands of
> contributors throughout the tree agree.
> This is entirely a Miller thing.

Nope.  There have been many efforts to
help standardize on single form styles.

> My main objection to these sweeping patches is that it makes it much
> more difficult to maintain and apply patches across different versions of
> the tree.

I think you underestimate the value of
standardization and overestimate the
quantity of work to sort it out for
the -stable versions.

cheers, Joe
