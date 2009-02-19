From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30] cxgb3: Add support for PCI ID 0x35.
Date: Wed, 18 Feb 2009 17:48:35 -0800 (PST)
Message-ID: <20090218.174835.12982157.davem@davemloft.net>
References: <20090216044615.24884.9331.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41246
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751381AbZBSBsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:48:51 -0500
In-Reply-To: <20090216044615.24884.9331.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Sun, 15 Feb 2009 20:46:15 -0800

> Add support for adapters with a PCI id equal to 0x35.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Adding new IDs is something we can do in net-2.6, so I'm
going to add this patch there.

Let me know if you don't want me to do that, or if there
is some dependency with net-next-2.6 that I'm not seeing.

Thanks!
