From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 11:06:50 +0200
Message-ID: <20090827090650.GA4260@elte.hu>
References: <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908261913030.11291@gandalf.stny.rr.com> <20090827001426.GA26475@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908262021300.18923@gandalf.stny.rr.com> <20090827011718.GA5315@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:54164 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833AbZH0JHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 05:07:10 -0400
Content-Disposition: inline
In-Reply-To: <20090827011718.GA5315@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Neil Horman <nhorman@tuxdriver.com> wrote:

> > TRACE_EVENT can be a little harder to learn, because it is all 
> > MACRO magic, but once you understand them, you'll find that they 
> > are very easy.
> 
> Yeah, macro magic is an understatement.  But I'll have the 
> conversions done in the next few days, no worries.

Cool, thanks Neil!

[ And we tracing folks are rather fond of that macro abuse, so if 
  you can think of ways it could be made even more abusively 
  C-alike, we are all ears ;-) ]

	Ingo
