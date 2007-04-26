From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/15] sunrpc: cleanup: use seq_release_private() where
 appropriate
Date: Thu, 26 Apr 2007 01:04:00 -0700 (PDT)
Message-ID: <20070426.010400.35468950.davem@davemloft.net>
References: <200704260727.l3Q7RR5a023964@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mp3@de.ibm.com, neilb@suse.de,
	trond.myklebust@fys.uio.no
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43474
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933638AbXDZIDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:03:52 -0400
In-Reply-To: <200704260727.l3Q7RR5a023964@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:27 -0700

> From: Martin Peschke <mp3@de.ibm.com>
> 
> We can save some lines of code by using seq_release_private().
> 
> Signed-off-by: Martin Peschke <mp3@de.ibm.com>
> Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
> Acked-by: Neil Brown <neilb@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thank you.
