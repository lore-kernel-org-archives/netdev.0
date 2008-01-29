From: David Miller <davem@davemloft.net>
Subject: Re: [0/3] [IPSEC]: Add async/aead support
Date: Mon, 28 Jan 2008 19:38:25 -0800 (PST)
Message-ID: <20080128.193825.193727574.davem@davemloft.net>
References: <20080129031047.GA13625@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52100
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752002AbYA2DiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 22:38:08 -0500
In-Reply-To: <20080129031047.GA13625@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 29 Jan 2008 14:10:47 +1100

> Hi Dave:
> 
> I've rebased the IPsec AEAD/async patches for the current net-2.6.25
> tree.

I've queued this up into a local tree, thanks Herbert.

I'm going to keep the real net-2.6.25.git tree untouched
until Linus pulls since the last thing I want to do is
screw up that merge :-)
