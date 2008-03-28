From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-2.6.26 - Rename inet_frag.h identifiers COMPLETE,
 FIRST_IN, LAST_IN to INET_FRAG_*
Date: Fri, 28 Mar 2008 16:35:36 -0700 (PDT)
Message-ID: <20080328.163536.254060614.davem@davemloft.net>
References: <20080328032449.cbc09f3b.akpm@linux-foundation.org>
	<1206728791.3445.39.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jirislaby@gmail.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754422AbYC1Xfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:35:42 -0400
In-Reply-To: <1206728791.3445.39.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 28 Mar 2008 11:26:31 -0700

> On Fri, 2008-03-28 at 03:24 -0700, Andrew Morton wrote:
> > they should all be renamed.
> 
> Done for include/net and net
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
