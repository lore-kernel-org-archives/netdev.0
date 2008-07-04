From: David Miller <davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 13:52:58 -0700 (PDT)
Message-ID: <20080704.135258.255741026.davem@davemloft.net>
References: <20080704.133721.98729739.davem@davemloft.net>
	<20080704134208.6c712031@infradead.org>
	<1215204218.3189.8.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, jeff@garzik.org, andi@firstfloor.org,
	tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752232AbYGDUw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 16:52:58 -0400
In-Reply-To: <1215204218.3189.8.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 04 Jul 2008 21:43:38 +0100

> He must do. After all, I was working for Red Hat when I started on
> cleaning up these drivers.

Then I hope you've caught the e100 ucode in your changes, for
the sake of full transparency :-)
