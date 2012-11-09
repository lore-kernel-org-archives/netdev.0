From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] UAPI: Fix compilation of the wanxl firmware blob.
Date: Fri, 09 Nov 2012 16:29:09 -0500 (EST)
Message-ID: <20121109.162909.1684134351246747559.davem@davemloft.net>
References: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, linux@arm.linux.org.uk
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab2KIV3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:29:12 -0500
In-Reply-To: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 07 Nov 2012 12:37:09 +0000

> The wanxl firmware needs access to some bits of UAPI stuff, so the -I flag in
> the Makefile needs adjusting to point at the UAPI headers.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied to net-next.
