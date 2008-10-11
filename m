From: David Miller <davem@davemloft.net>
Subject: Re: pkt_sched: cls_u32: Fix locking in u32_delete()
Date: Sat, 11 Oct 2008 15:05:45 -0700 (PDT)
Message-ID: <20081011.150545.03070833.davem@davemloft.net>
References: <E1KofAk-0001uJ-0q@gondolin.me.apana.org.au>
	<20081011.122400.51934908.davem@davemloft.net>
	<20081011220418.GA2540@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, m0sia@plotinka.ru,
	akpm@linux-foundation.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755390AbYJKWGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 18:06:09 -0400
In-Reply-To: <20081011220418.GA2540@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 12 Oct 2008 00:04:18 +0200

> Yes, you could be missing something, but I've forgotten what, because
> when I found this I was much younger and brighter... and alas now I've
> a busy weekend, so let it wait until monday.

You euros and your "weekends". :-)


