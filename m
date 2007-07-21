From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: 21 Jul 2007 15:26:00 +0200
Message-ID: <p73lkd9vqfr.fsf@bingen.suse.de>
References: <20070720.223129.59470764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:54250 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764169AbXGUMbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 08:31:03 -0400
In-Reply-To: <20070720.223129.59470764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> Good candidates for taking advantage of multi-napi are:
> 
> 1) e1000
> 2) ucc_geth
> 3) ehea
> 4) sunvnet

s2io.c

-Andi

