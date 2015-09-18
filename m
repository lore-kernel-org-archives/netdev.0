From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH next 0/30] Passing net through the netfilter hooks
Date: Fri, 18 Sep 2015 10:56:14 +0200
Message-ID: <20150918085614.GA3700@salvia>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <20150917.171904.119452251415625585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48230 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbbIRIth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 04:49:37 -0400
Content-Disposition: inline
In-Reply-To: <20150917.171904.119452251415625585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 05:19:04PM -0700, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 15 Sep 2015 19:59:49 -0500
> 
> > Pablo, Dave I don't know whose tree this makes more sense to go
> > through.  I am assuming at least initially Pablos as netfilter is
> > involved.  From what I have seen there will be a lot of back and forth
> > between the netfilter code paths and the routing code paths.
> 
> I think it might reduce conflicts actually if it went via my net-next
> tree.
> 
> Pablo, any objections?

This looks good, thanks for taking these David.
