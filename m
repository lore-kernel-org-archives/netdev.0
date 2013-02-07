From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next v2 0/2] xfrm: make gc_thresh configurable in
 all namespaces
Date: Thu, 7 Feb 2013 11:52:15 +0100
Message-ID: <20130207105215.GB17794@secunet.com>
References: <cover.1360143430.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35383 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757693Ab3BGKwV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 05:52:21 -0500
Content-Disposition: inline
In-Reply-To: <cover.1360143430.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 10:46:13AM +0100, Michal Kubecek wrote:
> Changes from original version:
> 
> - remove unused xfrm4_fini() to avoid section mismatch
> - don't mark xfrm6_net_ops as __net_initdata to avoid section mismatch
> 
> Michal Kubecek (2):
>   xfrm: remove unused xfrm4_policy_fini()
>   xfrm: make gc_thresh configurable in all namespaces

Applied to ipsec-next, thanks!
