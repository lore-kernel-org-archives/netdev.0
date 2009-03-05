From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] sfc: modify allocation error message
Date: Wed, 04 Mar 2009 17:39:09 -0800 (PST)
Message-ID: <20090304.173909.227714742.davem@davemloft.net>
References: <200903042003.n24K3BaX028938@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, travis@sgi.com, bhutchings@solarflare.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752995AbZCEBjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 20:39:24 -0500
In-Reply-To: <200903042003.n24K3BaX028938@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 04 Mar 2009 12:03:10 -0800

> From: Mike Travis <travis@sgi.com>
> 
> Change error message when alloc_cpumask_var fails.
> 
> Signed-off-by: Mike Travis <travis@sgi.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Yes, please get this into the tree where it applies and is
necessary, which as a reminder is not the networking tree :-)
