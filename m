From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Mon, 11 Jul 2011 04:41:49 -0700 (PDT)
Message-ID: <20110711.044149.856926004820244095.davem@davemloft.net>
References: <CAMuHMdXfpbbfv7oT+0oDWJd0=x0BBqEeCcGWaxMHagTXoeCscQ@mail.gmail.com>
	<1310377198.26989.90.camel@jtkirshe-mobl>
	<20110711113128.GA21187@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, geert@linux-m68k.org,
	netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab1GKLoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 07:44:04 -0400
In-Reply-To: <20110711113128.GA21187@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 11 Jul 2011 07:31:28 -0400

> But what whole vendor split, even if consistently implemented seems
> like a lot of wanking for very little juice.

There's simply too much stuff under drivers/net right now, I
want TAB completion to actually start being useful again.
