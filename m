From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 net-next 2/2] netns: exclude ipvs from struct net when
 IPVS disabled
Date: Wed, 26 Jun 2013 17:59:36 +0900
Message-ID: <20130626085935.GC24362@verge.net.au>
References: <20130624.002401.1459814761780281188.davem@davemloft.net>
 <1372236006-16683-1-git-send-email-junwei.zhang@6wind.com>
 <1372236006-16683-2-git-send-email-junwei.zhang@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, wensong@linux-vs.org, ja@ssi.bg,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: junwei.zhang@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:32975 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383Ab3FZI7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 04:59:38 -0400
Content-Disposition: inline
In-Reply-To: <1372236006-16683-2-git-send-email-junwei.zhang@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 04:40:06PM +0800, junwei.zhang@6wind.com wrote:
> From: JunweiZhang <junwei.zhang@6wind.com>
> 
> no real problem is fixed, just save a few bytes in
> net_namespace structure.
> 
> Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied to ipvs-next.
