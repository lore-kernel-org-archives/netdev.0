From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6/stable] [XFRM] AUDIT: Fix flowlabel text format.
Date: Sat, 26 Apr 2008 20:25:58 -0700 (PDT)
Message-ID: <20080426.202558.208247674.davem@davemloft.net>
References: <20080427.122418.32604330.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756555AbYD0DZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 23:25:59 -0400
In-Reply-To: <20080427.122418.32604330.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sun, 27 Apr 2008 12:24:18 +0900 (JST)

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

You'll have to be more specific than just saying "fixed"
when you submit a patch like this.

What about the format is it fixing?

Also, can this possibly break existing audit log scanning
tools and parsers?
