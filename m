From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 16:33:37 +0900
Message-ID: <20100830073337.GD2094@verge.net.au>
References: <20100830062755.GA22396@verge.net.au>
 <1283151125.7762.77.camel@Joe-Laptop>
 <20100830071147.GB22396@verge.net.au>
 <1283153118.7762.83.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47120 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab0H3Hdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 03:33:41 -0400
Content-Disposition: inline
In-Reply-To: <1283153118.7762.83.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 12:25:18AM -0700, Joe Perches wrote:
> On Mon, 2010-08-30 at 16:11 +0900, Simon Horman wrote:
> > On Sun, Aug 29, 2010 at 11:52:05PM -0700, Joe Perches wrote:
> > > On Mon, 2010-08-30 at 15:27 +0900, Simon Horman wrote:
> > > > I am looking to submit the Open vSwitch datapath for merging into the
> > > > kernel.  To this end I have posted a preliminary round of patches to the
> > > > dev@openvswitch.org mailing list
> > > > 2) The code could do with some cleaning up. The current todo list
> > > >    includes the following items.
> > > >    * Use pr_*
> > > >    * Remove trailing whitespace and other formatting fixes
> > > These are trivial and easy to fix via script.
> > > I think these should be done prior to being merged.
> > > I've got patches if you want them.
> > Yes, please send them.
> 
> I've send them to you and cc'd the dev@openvswitch.org mailing list.

Thanks
