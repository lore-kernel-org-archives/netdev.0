From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH Round 3 0/2][RFC] Network Event Notifier Mechanism
Date: Wed, 28 Jun 2006 12:54:10 +1000
Message-ID: <E1FvQBu-00018u-00@gondolin.me.apana.org.au>
References: <20060627205050.30723.25753.stgit@stevo-desktop>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55817 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422937AbWF1CyZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 22:54:25 -0400
To: swise@opengridcomputing.com (Steve Wise)
In-Reply-To: <20060627205050.30723.25753.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise <swise@opengridcomputing.com> wrote:
> 
> The reason these devices need update events is because they typically
> cache this information in hardware and need to be notified when this
> information has been updated.  For information on RDMA protocols, see:
> http://www.ietf.org/html.charters/rddp-charter.html.

Please give more specific reasons for needing these events because it
is certainly far from obvious from reading those documents.

Without reasons these invasive changes may turn out to be completely
inappropriate.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
