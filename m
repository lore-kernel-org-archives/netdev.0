From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [IPV4]: Convert IPv4 devconf to an array
Date: Mon, 04 Jun 2007 23:34:55 -0700 (PDT)
Message-ID: <20070604.233455.97295112.davem@davemloft.net>
References: <20070605062929.GA12024@gondor.apana.org.au>
	<E1HvSZK-0003A7-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36093
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752794AbXFEGek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:34:40 -0400
In-Reply-To: <E1HvSZK-0003A7-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 05 Jun 2007 16:31:02 +1000

> [IPV4]: Convert IPv4 devconf to an array
> 
> This patch converts the ipv4_devconf config members (everything except
> sysctl) to an array.  This allows easier manipulation which will be
> needed later on to provide better management of default config values.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
