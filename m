From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
Date: Thu, 29 Jun 2006 17:12:47 -0700 (PDT)
Message-ID: <20060629.171247.85410715.davem@davemloft.net>
References: <Pine.GSO.4.10.10606291810490.12773-100000@guinness>
	<E1Fw604-0006yP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@osdl.org,
	Leonid.Grossman@neterion.com, Ravinandan.Arakali@neterion.com,
	sivakumar.subramani@neterion.com, Sriram.Rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61365
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933161AbWF3AMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:12:50 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1Fw604-0006yP-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jun 2006 09:32:44 +1000

> BTW, you should rediff against Dave's current tree which has a few
> extra bits there.

I just rebased that, so feel free to use it as the base for
the patch now.
