From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: add my copyright statements
Date: Fri, 19 Apr 2013 00:14:52 +0200
Message-ID: <20130418221450.GA10218@localhost>
References: <1365254669-18964-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44603 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936446Ab3DRWO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 18:14:56 -0400
Content-Disposition: inline
In-Reply-To: <1365254669-18964-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 06, 2013 at 03:24:29PM +0200, Patrick McHardy wrote:
> Add copyright statements to all netfilter files which have had significant
> changes done by myself in the past.
> 
> Some notes:
> 
> - nf_conntrack_ecache.c was incorrectly attributed to Rusty and Netfilter
>   Core Team when it got split out of nf_conntrack_core.c. The copyrights
>   even state a date which lies six years before it was written. It was
>   written in 2005 by Harald and myself.
> 
> - net/ipv{4,6}/netfilter.c, net/netfitler/nf_queue.c were missing copyright
>   statements. I've added the copyright statement from net/netfilter/core.c,
>   where this code originated
> 
> - for nf_conntrack_proto_tcp.c I've also added Jozsef, since I didn't want
>   it to give the wrong impression

Applied, thanks Patrick.
