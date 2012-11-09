From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] Make the wanxl firmware array const
Date: Fri, 09 Nov 2012 16:29:33 -0500 (EST)
Message-ID: <20121109.162933.2195273239440440489.davem@davemloft.net>
References: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
	<20121107123731.4147.57657.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, linux@arm.linux.org.uk
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab2KIV3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:29:34 -0500
In-Reply-To: <20121107123731.4147.57657.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 07 Nov 2012 12:37:31 +0000

> Make the wanxl firmware array const so that it goes in the read-only section.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied to net-next.
