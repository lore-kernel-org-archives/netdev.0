From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable v2 0/3] virtio-net: backport error handling
 bugfix
Date: Wed, 01 Jan 2014 23:16:40 -0500 (EST)
Message-ID: <20140101.231640.983120067744057608.davem@davemloft.net>
References: <1388064752-15734-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaABEQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:16:42 -0500
In-Reply-To: <1388064752-15734-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 26 Dec 2013 15:32:44 +0200

> Error handling for virtio-net mergeable buffers was broken
> for a long time. Backport recent bugfix to a stable
> kernel.
> 
> Please note that it's really a single change split out for ease of
> review - that's why 2/2 is here even though it's not
> stricktly a bugfix - the code becomes too confusing without it.
> 
> Please review and consider for stable.

Queued up for -stable, thanks Michael.
