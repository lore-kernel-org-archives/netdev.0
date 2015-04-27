From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: remove the xfrm_queue_purge definition
Date: Mon, 27 Apr 2015 12:35:22 +0200
Message-ID: <20150427103521.GJ8928@secunet.com>
References: <1429689076-10684-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47716 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932413AbbD0KfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 06:35:25 -0400
Content-Disposition: inline
In-Reply-To: <1429689076-10684-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 03:51:16PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The task of xfrm_queue_purge is same as skb_queue_purge, so remove it
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to ipsec-next, thanks!
