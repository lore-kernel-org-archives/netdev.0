From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule modifications
Date: Thu, 29 Mar 2007 12:15:57 +0200
Message-ID: <20070329101557.GB1772@ff.dom.local>
References: <20070327133845.GM521@postel.suug.ch> <20070328111921.GA2703@ff.dom.local> <20070328154903.GO521@postel.suug.ch> <20070328.112417.08322226.davem@davemloft.net> <20070328193436.GP521@postel.suug.ch> <20070329100326.GA1772@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	muli@il.ibm.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:55309 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934173AbXC2KLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 06:11:10 -0400
Content-Disposition: inline
In-Reply-To: <20070329100326.GA1772@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2007 at 12:03:26PM +0200, Jarek Poplawski wrote:
...
> rt_cache_flush - it's not for all (I know - we don't like
> multipath - but untill it's here...)[...] 

Sorry, I forgot it's already not there...

Jarek P.
