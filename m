From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: fib_hash removal
Date: Thu, 15 Mar 2007 10:42:35 +0100
Message-ID: <20070315094235.GA2919@ff.dom.local>
References: <20070315074046.GA1671@ff.dom.local> <45F8F93F.6010408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, tgr@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:52965 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752776AbXCOJiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 05:38:20 -0400
Content-Disposition: inline
In-Reply-To: <45F8F93F.6010408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 08:43:59AM +0100, Patrick McHardy wrote:
...
> Yes, Robert already sent me a patch to remove the bogus preempt_disable,

It looks like RCU could be endangered now.

Jarek P.
