From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] node-aware skb allocations
Date: Thu, 16 Nov 2006 02:53:20 -0800 (PST)
Message-ID: <20061116.025320.41632254.davem@davemloft.net>
References: <20061115173643.GA17695@lst.de>
	<20061115151646.9c8a6936.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41141
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423801AbWKPKxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 05:53:22 -0500
To: akpm@osdl.org
In-Reply-To: <20061115151646.9c8a6936.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Wed, 15 Nov 2006 15:16:46 -0800

> If Dave wants to nod at it then I can merge all of it, else I can hand
> patch 3/3 over to Dave once its prerequisites are in mainline.

I'm completely fine with this, nice work Christoph.
Andrew, just toss it all into your tree for now.
