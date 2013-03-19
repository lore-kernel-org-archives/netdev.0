From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf] IPVS fixes for v3.9
Date: Tue, 19 Mar 2013 21:15:19 +0900
Message-ID: <20130319121518.GD4317@verge.net.au>
References: <1363657198-5333-1-git-send-email-horms@verge.net.au>
 <20130319094555.GB3602@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59207 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab3CSMPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 08:15:22 -0400
Content-Disposition: inline
In-Reply-To: <20130319094555.GB3602@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 10:45:55AM +0100, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> I proposed this:
> 
> > I think that these three fixes:
> >
> > ipvs: add backup_only flag to avoid loops
> > ipvs: remove extra rcu lock
> > ipvs: fix sctp chunk length order
> >
> > should find their path to the net tree.
> >
> > The remaining two sparse fixes should go to net-next.
> 
> But you sent me these for net:
> 
> ipvs: fix sctp chunk length order
> ipvs: fix hashing in ip_vs_svc_hashkey
> ipvs: fix some sparse warnings
> 
> that doesn't match.
> 
> Can you resolve this? Thanks.

Oops, will do.
