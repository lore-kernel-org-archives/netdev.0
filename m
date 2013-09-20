From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Fri, 20 Sep 2013 12:21:42 -0400 (EDT)
Message-ID: <20130920.122142.1032350399957506112.davem@davemloft.net>
References: <523C7464.3070007@suse.cz>
	<20130920.121535.1653382964468102292.davem@davemloft.net>
	<523C753A.8040401@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, akpm@linux-foundation.org, jeffm@suse.com,
	netdev@vger.kernel.org, isdn4linux@koppen.de, isdn@linux-pingi.de,
	sergei.shtylyov@cogentembedded.com
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab3ITQVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:21:44 -0400
In-Reply-To: <523C753A.8040401@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 20 Sep 2013 18:18:02 +0200

> Ok, let's leave the hole in there then.

Jiri, don't turn this on me.

The issue is not whether something needs to be fixed or not, I never
said "don't fix this" and therefore I'd like to ask politely that you
not make it seem like I have.

Rather, I'm saying that the implementation is terrible, sets a bad
precendence for fixing similar problems, and therefore not is in
a state where we can apply it.

So, I'm not saying "don't fix this", I'm saying "fix it properly."
