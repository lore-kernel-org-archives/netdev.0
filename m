From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM_TUNNEL]: Reload header pointer after
 pskb_may_pull/pskb_expand_head
Date: Sat, 24 Feb 2007 18:13:46 -0800 (PST)
Message-ID: <20070224.181346.07640056.davem@davemloft.net>
References: <39e6f6c70702241747l19dd1b21l9a28f7d6f64a4a6f@mail.gmail.com>
	<39e6f6c70702241749l4c7128afyeed881245c2e3ac2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: arnaldo.melo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933616AbXBYCNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 21:13:49 -0500
In-Reply-To: <39e6f6c70702241749l4c7128afyeed881245c2e3ac2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sat, 24 Feb 2007 23:49:50 -0200

> Oops, now with the patch.

Thanks, applied.

I'll queue this one up for -stable too.
