From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie resize break
Date: Mon, 19 Mar 2007 16:27:57 -0700 (PDT)
Message-ID: <20070319.162757.07640692.davem@davemloft.net>
References: <17914.30097.150726.261688@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jens.Laas@data.slu.se, hans.liss@its.uu.se
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966052AbXCSX2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 19:28:07 -0400
In-Reply-To: <17914.30097.150726.261688@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Fri, 16 Mar 2007 11:46:41 +0100

> 
> Hello.
> 
> The patch below adds break condition for the resize operations. If 
> we don't achieve the desired fill factor a warning is printed. Trie 
> should still be operational but new thresholds should be considered.
> 
> Cheers
> 					--ro
> 
> 
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied with whitespace problems fixed up to net-2.6.22, thanks.
