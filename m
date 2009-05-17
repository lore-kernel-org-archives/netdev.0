From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] sfc: modify allocation error message
Date: Sun, 17 May 2009 13:59:06 -0700 (PDT)
Message-ID: <20090517.135906.211922861.davem@davemloft.net>
References: <200905122107.n4CL7p7c010639@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, travis@sgi.com, bhutchings@solarflare.com,
	mingo@elte.hu, rusty@rustcorp.com.au
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755252AbZEQU7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 16:59:08 -0400
In-Reply-To: <200905122107.n4CL7p7c010639@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 12 May 2009 13:48:36 -0700

> From: Mike Travis <travis@sgi.com>
> 
> Change error message when alloc_cpumask_var fails.
> 
> Repairs "cpumask: convert drivers/net/sfc".
> 
> Signed-off-by: Mike Travis <travis@sgi.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6
