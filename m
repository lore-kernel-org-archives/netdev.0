From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: fib_hash removal
Date: Thu, 15 Mar 2007 10:23:29 +0100
Message-ID: <20070315092328.GC1671@ff.dom.local>
References: <20070315074046.GA1671@ff.dom.local> <45F8F93F.6010408@trash.net> <20070315091544.GB1671@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, tgr@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:48689 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752689AbXCOJTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 05:19:13 -0400
Content-Disposition: inline
In-Reply-To: <20070315091544.GB1671@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 10:15:44AM +0100, Jarek Poplawski wrote:
...
> BTW: it seems fib_tree wasn't used too much, so probably,
> before killing fib_hash, fib_tree should be made Kconfig
> default for some time.

Sorry! Let fib_tree stay out of Kconfig and make fib_trie
the default.

Jarek P.
