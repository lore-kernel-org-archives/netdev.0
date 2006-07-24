From: Andi Kleen <ak@suse.de>
Subject: Re: What is RDMA
Date: Tue, 25 Jul 2006 00:49:14 +0200
Message-ID: <200607250049.14666.ak@suse.de>
References: <1152163503.20248.98.camel@trinity.ogc.int> <20060724.152925.85821176.davem@davemloft.net> <44C54AF6.3030609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	tom@opengridcomputing.com, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:51673 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932312AbWGXWva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 18:51:30 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44C54AF6.3030609@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 July 2006 00:34, Rick Jones wrote:
> That TOE/iWARP could end-up being precluded by NAT seems so ironic from a POE2E 
> standpoint.

Yes, it's sad, but reality unfortunately. 

There is even precedent: the VJ stateless TW recycling scheme also
turned out to not work because of NAT considerations.

-Andi
