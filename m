From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: Document xfrm4_gc_thresh and
 xfrm6_gc_thresh
Date: Tue, 11 Aug 2015 13:51:52 -0700 (PDT)
Message-ID: <20150811.135152.34039482191606454.davem@davemloft.net>
References: <20150811203501.1914.86746.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932447AbbHKUvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 16:51:52 -0400
In-Reply-To: <20150811203501.1914.86746.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 11 Aug 2015 13:35:01 -0700

> This change adds documentation for xfrm4_gc_thresh and xfrm6_gc_thresh
> based on the comments in commit eeb1b73378b56 ("xfrm: Increase the garbage
> collector threshold").
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Thanks, I'll let Steffen review and pick this up.
