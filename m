From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] BUG: NULL pointer dereference in(?)
 ip6_flush_pending_frames
Date: Tue, 11 Sep 2007 02:32:18 -0700 (PDT)
Message-ID: <20070911.023218.39155851.davem@davemloft.net>
References: <20070909222400.GC7591@obelix.birkenwald.de>
	<20070910.083847.40751994.yoshfuji@linux-ipv6.org>
	<46E4FDC6.3060809@birkenwald.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	miyazawa@linux-ipv6.org
To: berni@birkenwald.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:51824
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752447AbXIKJc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 05:32:27 -0400
In-Reply-To: <46E4FDC6.3060809@birkenwald.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Schmidt <berni@birkenwald.de>
Date: Mon, 10 Sep 2007 10:18:14 +0200

> FTR, I tried 2.6.22.6 without the patch and it failed as well. The 
> patched kernel is running since yesterday evening (about 8h now) and 
> seems to be stable so far. Too early to tell for sure, but I guess we 
> have a fix.
> 
> Thanks Yoshifuji!

I've applied this fix, thanks!
