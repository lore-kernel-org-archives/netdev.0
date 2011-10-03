From: David Miller <davem@davemloft.net>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Mon, 03 Oct 2011 12:20:20 -0400 (EDT)
Message-ID: <20111003.122020.753253567760292779.davem@davemloft.net>
References: <20110927202405.GB27713@redhat.com>
	<1317155839.2472.5.camel@edumazet-laptop>
	<20111003161346.GA30201@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab1JCQU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 12:20:28 -0400
In-Reply-To: <20111003161346.GA30201@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 3 Oct 2011 12:13:46 -0400

> Just to close this discussion, the user reported that he built a 3.1.0rc7 kernel,
> and couldn't reproduce this bug any more, so it was something that got fixed
> that didn't make it to the longterm stable releases.

Thanks for the update Dave.
