From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Tue, 23 Apr 2013 09:23:45 -0400
Message-ID: <20130423132345.GA5564@hmsreliant.think-freely.org>
References: <20130412113232.GA19966@hmsreliant.think-freely.org>
 <516813A0.1040300@acm.org>
 <20130412184542.GB19966@hmsreliant.think-freely.org>
 <51690AAB.1030102@acm.org>
 <20130415141610.GA3505@hmsreliant.think-freely.org>
 <CAO+b5-oBfH3M0dnrQSs-p1BF_5hKy2tsU-dD=EP9+S=iqPs5ew@mail.gmail.com>
 <20130416172454.GC9241@hmsreliant.think-freely.org>
 <20130418192912.GB29130@hmsreliant.think-freely.org>
 <20130422201246.GA20687@hmsreliant.think-freely.org>
 <CAO+b5-r5jVJNZWuREUH5MQ3baeSPR8fVV1p9pMnukmiZd9nRhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Bart Van Assche <bart.vanassche@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49974 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857Ab3DWNX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 09:23:57 -0400
Content-Disposition: inline
In-Reply-To: <CAO+b5-r5jVJNZWuREUH5MQ3baeSPR8fVV1p9pMnukmiZd9nRhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 01:41:11PM -0700, Bart Van Assche wrote:
> On Mon, Apr 22, 2013 at 1:12 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > Bart, any testing/thoughts here?  i'd like to get this fixed in the next
> > few
> > days, but I'd like to get any feedback you might have first.
> >
> 
> Sorry but I haven't been able to run any tests during the past eight days
> since I'm traveling and because of that I do not have access to my regular
> test setup.
> 
> Bart.
Copy that.  I can propose this change based on my own testing, or wait for you
to get back.  Do you have a preference?
Neil
