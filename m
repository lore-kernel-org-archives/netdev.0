From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] dont insert sockets/pipes dentries into
 dentry_hashtable.
Date: Wed, 01 Nov 2006 00:34:31 -0800 (PST)
Message-ID: <20061101.003431.129059138.davem@davemloft.net>
References: <200610311948.48970.dada1@cosmosbay.com>
	<20061031.231954.23010447.davem@davemloft.net>
	<454858F2.5020206@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27595
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423685AbWKAIea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 03:34:30 -0500
To: dada1@cosmosbay.com
In-Reply-To: <454858F2.5020206@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 01 Nov 2006 09:21:06 +0100

> No no, my patch takes care of that.
> 
> You still see the right link for pipes and sockets on /proc/$pid/fd/XXX
> 
> And " (deleted)" is correctly added to deleted files.

I see.  Excellent :-)
