From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MD5: don't warn when an unexpected signature is seen.
Date: Wed, 30 Jul 2008 01:59:45 -0700 (PDT)
Message-ID: <20080730.015945.193695120.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069040@europa>
	<alpine.LRH.1.10.0807301145030.14882@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752020AbYG3I7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 04:59:46 -0400
In-Reply-To: <alpine.LRH.1.10.0807301145030.14882@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Savola <pekkas@netcore.fi>
Date: Wed, 30 Jul 2008 11:45:50 +0300 (EEST)

> Just wondering.  If the warning is removed, should this be tracked 
> somewhere else, e.g. 'netstat -s' TCP statistics?

Yes, this is what should be done.

I was going to mention this when I got to this patch in my backlog.
