From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 1/2] netfilter: ip6t_SYNPROXY: fix NULL pointer
 dereference
Date: Mon, 10 Aug 2015 13:58:17 +0200
Message-ID: <20150810115817.GA3260@salvia>
References: <20150808155746.GC29362@acer.localdomain>
 <1439118856-26484-1-git-send-email-phil@nwl.cc>
 <20150810075721.GB20899@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56726 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391AbbHJLwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 07:52:13 -0400
Content-Disposition: inline
In-Reply-To: <20150810075721.GB20899@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2015 at 09:57:21AM +0200, Patrick McHardy wrote:
> On 09.08, Phil Sutter wrote:
> > This happens when networking namespaces are enabled.
> > 
> > Suggested-by: Patrick McHardy <kaber@trash.net>
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks!
