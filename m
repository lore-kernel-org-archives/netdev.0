From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: BPF 'JIT' compiler for PPC64
Date: Mon, 18 Jul 2011 12:42:48 -0700 (PDT)
Message-ID: <20110718.124248.1462465498024218250.davem@davemloft.net>
References: <4E23E5C3.1070209@ozlabs.org>
	<1310978375.5756.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matt@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab1GRTo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 15:44:56 -0400
In-Reply-To: <1310978375.5756.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 Jul 2011 10:39:35 +0200

> So in PPC SEEN_XREG only is to be set of X is read, not if written.
> 
> So you dont have to set SEEN_XREG bit in this part :

Matt, do you want to integrate changes based upon Eric's feedback
here or do you want me to apply your patch as-is for now?

Thanks.
