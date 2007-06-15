From: David Miller <davem@davemloft.net>
Subject: Re: [RFC: 2.6 patch] net/rxrpc/ar-output.c: remove dead code
Date: Fri, 15 Jun 2007 15:16:40 -0700 (PDT)
Message-ID: <20070615.151640.99201246.davem@davemloft.net>
References: <20070615214520.GM3588@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755601AbXFOWQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 18:16:22 -0400
In-Reply-To: <20070615214520.GM3588@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 15 Jun 2007 23:45:20 +0200

> This patch removes dead code spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

I'll let David H. decide how to handle these cleanups
and simplifications.  Thanks Adrian.
