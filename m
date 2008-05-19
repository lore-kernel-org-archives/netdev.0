From: "Bradley M. Kuhn" <bkuhn@ebb.org>
Subject: Re: [Bugme-new] [Bug 10682] New: (net 8139too) dual ethernet   system, any reasonable network causes: NETDEV WATCHDOG: ethN: transmit   timed out
Date: Sun, 18 May 2008 22:05:02 -0400
Message-ID: <87d4njnj5d.fsf@ebb.org>
References: <bug-10682-10286@http.bugzilla.kernel.org/>
	<20080511211055.af2595e9.akpm@linux-foundation.org>
	<20080512214014.GB27236@ebb.org>
	<20080512151142.067b98d2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sflc.info ([216.27.154.199]:51481 "EHLO mail.sflc.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbYESC3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 22:29:24 -0400
In-Reply-To: <20080512151142.067b98d2.akpm@linux-foundation.org> (Andrew
	Morton's message of "Mon, 12 May 2008 15:11:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote:
>> I reported this bug:
>> > > http://bugzilla.kernel.org/show_bug.cgi?id=10682
>> > >            Summary: (net 8139too) dual ethernet system, any reasonable
>> > >                     network causes: NETDEV WATCHDOG: ethN: transmit timed
>> > >                     out
>> > >      KernelVersion: 2.6.25.3

>> Andrew Morton replied:
> I think [trying] an early 2.6 would be a good place to start -
> 2.6.5. 2.6.9, etc.

I had trouble getting 2.6.5 onto the machine with the distribution it
had.  I have installed a different distribution, and now have 2.6.15
running, and it produces the same error.

So, we know the bug was present in 2.6.15.

Now that I have an older distribution, I should be able to try 2.6.5 and
2.6.9 shortly.  Do you expect it will produce substantially different
results from 2.6.15?

> If that doesn't help then we can probably safely assume that it's
> always been busted.  If that kernel works OK then we can drill in more
> cloesly, if you're so inclined (which we hope you are ;))

I'm absolutely inclinded to do so.  What can I do to get you more
information, other than the above?
-- 

   -- bkuhn
