From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV6 : get rid of __HAVE_ARCH_ADDR_SET
Date: Thu, 03 May 2007 03:09:03 -0700 (PDT)
Message-ID: <20070503.030903.123997453.davem@davemloft.net>
References: <4636BB49.8050307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751208AbXECKJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:09:03 -0400
In-Reply-To: <4636BB49.8050307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 01 May 2007 06:00:09 +0200

> __HAVE_ARCH_ADDR_SET seems unused these days, just get rid of it.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
