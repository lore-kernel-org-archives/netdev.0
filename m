From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: announce deleation of temporary SA
Date: Mon, 26 Aug 2013 12:54:39 +0200
Message-ID: <20130826105439.GL26773@secunet.com>
References: <1377265568-10959-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50430 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704Ab3HZKym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 06:54:42 -0400
Content-Disposition: inline
In-Reply-To: <1377265568-10959-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 03:46:08PM +0200, Nicolas Dichtel wrote:
> Creation of temporary SA are announced by netlink, but there is no notification
> for the deletion.
> This patch fix this asymmetric situation.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks good, applied to ipsec-next. Thanks!
