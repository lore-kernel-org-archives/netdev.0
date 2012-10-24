From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow configuration of the size of page in
 __netdev_alloc_frag
Date: Wed, 24 Oct 2012 14:19:32 -0400 (EDT)
Message-ID: <20121024.141932.1360126659291040918.davem@davemloft.net>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	konrad.wilk@oracle.com, xen-devel@lists.xen.org
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935434Ab2JXSTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 14:19:34 -0400
In-Reply-To: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm not applying this.

Fix your drivers and the infrastructure they use, don't paper
around it.
