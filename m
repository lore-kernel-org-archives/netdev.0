From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] textsearch: doc - fix spelling in lib/textsearch.c.
Date: Mon, 24 Jan 2011 23:33:41 -0800 (PST)
Message-ID: <20110124.233341.48490506.davem@davemloft.net>
References: <20110124124137.10202.47152.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sander.contrib@gmail.com
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702Ab1AYHdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 02:33:06 -0500
In-Reply-To: <20110124124137.10202.47152.stgit@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Mon, 24 Jan 2011 13:41:37 +0100

> Found the following spelling errors while reading the textsearch code:
>   "facitilies"  -> "facilities"
>   "continously" -> "continuously"
>   "arbitary"    -> "arbitrary"
>   "patern"      -> "pattern"
>   "occurences"  -> "occurrences"
> 
> I'll try to push this patch through DaveM, given the only users
> of textsearch is in the net/ tree (nf_conntrack_amanda.c, xt_string.c
> and em_text.c)
> 
> Signed-off-by: Jesper Sander <sander.contrib@gmail.com>
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Applied, thanks.
