From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/rxrpc/ar-connection.c: fix NULL dereference
Date: Fri, 15 Jun 2007 15:16:18 -0700 (PDT)
Message-ID: <20070615.151618.28395619.davem@davemloft.net>
References: <20070615214513.GL3588@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752247AbXFOWP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 18:15:59 -0400
In-Reply-To: <20070615214513.GL3588@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 15 Jun 2007 23:45:13 +0200

> This patch fixes a NULL dereference spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Looks good to me, patch applied, thanks Adrian.
