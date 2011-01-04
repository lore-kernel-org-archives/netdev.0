From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Tue, 4 Jan 2011 08:05:17 -0800
Message-ID: <20110104080517.104de07c@nehalam>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	<20101220232020.GB2052@del.dom.local>
	<1292887689.2627.150.camel@edumazet-laptop>
	<20101220235209.GA1865@del.dom.local>
	<1292939574.6535.27.camel@mojatatu>
	<AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	<20101221223704.GA1979@del.dom.local>
	<1293111333.11306.170.camel@mojatatu>
	<1294003631.2535.253.camel@edumazet-laptop>
	<20110103095842.7677130d@nehalam>
	<Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
	<1294153329.3579.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40347 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025Ab1ADQFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 11:05:21 -0500
In-Reply-To: <1294153329.3579.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am playing with Quick Fair Queue (QFQ) from FreeBSD.
The authors started with Linux first and sent me their version,
it needs some work first.

http://info.iet.unipi.it/~luigi/qfq/

http://www.google.com/search?client=ubuntu&channel=fs&q=QFQ+rizzo&ie=utf-8&oe=utf-8
