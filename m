From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 RESEND] xfrm: remove unneeded method
 typedef declaration in net/xfrm.h.
Date: Sat, 25 Feb 2012 20:19:44 -0500 (EST)
Message-ID: <20120225.201944.1461370712655927034.davem@davemloft.net>
References: <CAHLOa7Qz83kBc9xFeEXuiEWTq+C4bVoxD6bDt_3-ufGd7VrSDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab2BZBTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 20:19:48 -0500
In-Reply-To: <CAHLOa7Qz83kBc9xFeEXuiEWTq+C4bVoxD6bDt_3-ufGd7VrSDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Sat, 25 Feb 2012 14:09:46 +0200

>  The patch removes unneeded method typedef declaration
> (icv_update_fn_t ) and the two struct declarations which appear in
> its prototype (struct hash_desc and struct scatterlist) in net/xfrm.h.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
