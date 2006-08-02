From: David Miller <davem@davemloft.net>
Subject: Re: neigh_lookup lockdep bug.
Date: Wed, 02 Aug 2006 14:08:11 -0700 (PDT)
Message-ID: <20060802.140811.80030338.davem@davemloft.net>
References: <E1G7u9v-0001mL-00@gondolin.me.apana.org.au>
	<1154485629.3030.21.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davej@redhat.com,
	netdev@vger.kernel.org, mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33210
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932161AbWHBVIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 17:08:01 -0400
To: arjan@infradead.org
In-Reply-To: <1154485629.3030.21.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 02 Aug 2006 04:26:49 +0200

> fwiw the patch is at
> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/lockdep-split-the-skb_queue_head_init-lock-class.patch
> and a followup cleanup at
> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/lockdep-split-the-skb_queue_head_init-lock-class-tidy.patch

Both applied, thanks.
