From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Tue, 13 Mar 2012 10:07:37 -0400
Message-ID: <20120313140737.GA1424@redhat.com>
References: <20120310122725.GA31129@hostway.ca>
 <1331401490.2453.28.camel@edumazet-laptop>
 <1331402182.2453.30.camel@edumazet-laptop>
 <1331407221.2453.42.camel@edumazet-laptop>
 <20120313072643.GA32306@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
To: Simon Kirby <sim@netnation.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516Ab2CMOHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 10:07:42 -0400
Content-Disposition: inline
In-Reply-To: <20120313072643.GA32306@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 13, 2012 at 12:26:44AM -0700, Simon Kirby wrote:

 > Oops two seconds later, scrolled off console, didn't get written to disk
 > or remote syslog server, all we have is syslog-broadcasted Oops and Code
 > lines due to broken printk priorities:

I posted two reports we've had against Fedora yesterday which look like this bug.

https://bugzilla.redhat.com/show_bug.cgi?id=801599
https://bugzilla.redhat.com/show_bug.cgi?id=802660

	Dave
