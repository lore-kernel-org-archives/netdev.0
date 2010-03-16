From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix br_forward crash in promiscuous mode
Date: Tue, 16 Mar 2010 00:26:35 -0700 (PDT)
Message-ID: <20100316.002635.07203086.davem@davemloft.net>
References: <4B9C4A2F.8040203@fami-braun.de>
	<20100316030002.GA17632@gondor.apana.org.au>
	<20100316071914.GA19630@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael-dev@fami-braun.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756111Ab0CPH0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 03:26:14 -0400
In-Reply-To: <20100316071914.GA19630@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 16 Mar 2010 15:19:14 +0800

> bridge: Fix br_forward crash in promiscuous mode

Applied, thanks everyone.
