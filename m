From: Joe Perches <joe@perches.com>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 00:25:18 -0700
Message-ID: <1283153118.7762.83.camel@Joe-Laptop>
References: <20100830062755.GA22396@verge.net.au>
	 <1283151125.7762.77.camel@Joe-Laptop> <20100830071147.GB22396@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1057 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156Ab0H3HZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 03:25:20 -0400
In-Reply-To: <20100830071147.GB22396@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-30 at 16:11 +0900, Simon Horman wrote:
> On Sun, Aug 29, 2010 at 11:52:05PM -0700, Joe Perches wrote:
> > On Mon, 2010-08-30 at 15:27 +0900, Simon Horman wrote:
> > > I am looking to submit the Open vSwitch datapath for merging into the
> > > kernel.  To this end I have posted a preliminary round of patches to the
> > > dev@openvswitch.org mailing list
> > > 2) The code could do with some cleaning up. The current todo list
> > >    includes the following items.
> > >    * Use pr_*
> > >    * Remove trailing whitespace and other formatting fixes
> > These are trivial and easy to fix via script.
> > I think these should be done prior to being merged.
> > I've got patches if you want them.
> Yes, please send them.

I've send them to you and cc'd the dev@openvswitch.org mailing list.

