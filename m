From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: using rhashtable in inethash
Date: Mon, 25 Aug 2014 17:56:25 -0700
Message-ID: <20140826005625.GI2663@linux.vnet.ibm.com>
References: <20140825.161224.1108200625385309828.davem@davemloft.net>
 <1409009735.3173.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140825234231.GA9152@casper.infradead.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:38038 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179AbaHZA4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:56:30 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 25 Aug 2014 18:56:29 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 033A019D8039
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 18:56:15 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7Q0uRMq26738704
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 02:56:27 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s7Q10liX008510
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 19:00:48 -0600
Content-Disposition: inline
In-Reply-To: <20140825234231.GA9152@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2014 at 12:42:31AM +0100, Thomas Graf wrote:
> On 08/25/14 at 04:35pm, Eric Dumazet wrote:
> > Thomas agreed to work on all this. If not I can do this myself.
> 
> I already got started and will share the code as soon as I have
> something semi functional.

Very much looking forward to seeing it!

							Thanx, Paul
