From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [IPVS] transparent proxying
Date: Mon, 18 Dec 2006 15:17:48 +0100
Message-ID: <20061218141748.GA8693@postel.suug.ch>
References: <20061129062126.GP25535@verge.net.au> <20061129141523.GD8693@postel.suug.ch> <20061129144620.GA5978@verge.net.au> <20061218031931.GA1075@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Wensong Zhan <wensong@linux-vs.org>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	Jinhua Luo <home_king@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56419 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051AbWLROR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 09:17:28 -0500
To: Horms <horms@verge.net.au>
Content-Disposition: inline
In-Reply-To: <20061218031931.GA1075@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Horms <horms@verge.net.au> 2006-12-18 12:19
> On Wed, Nov 29, 2006 at 11:46:22PM +0900, Horms wrote:
> > On Wed, Nov 29, 2006 at 03:15:23PM +0100, Thomas Graf wrote:
> 
> [split]
> 
> > > This patch seems to be based on an old tree, I've renamed nfmark
> > > to mark in net-2.6.20. The term fwmark and nfmark shouldn't be
> > > used anymore.
> > 
> > Sorry, I based this patch on Linus's tree. I'll port it to net-2.6.20.
> 
> This took too long for me to get around to :(
> Am I correct in thinking I just need to replace fwmark with mark?

Yes, that's all there is to it.
