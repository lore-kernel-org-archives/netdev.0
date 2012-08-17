From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 0/1] sched: Add a new API to find the prefer idlest
 cpu
Date: Fri, 17 Aug 2012 09:58:11 -0700
Message-ID: <1345222691.16533.7.camel@oc3660625478.ibm.com>
References: <1343026634.13461.15.camel@oc3660625478.ibm.com>
	 <1345217986.16533.1.camel@oc3660625478.ibm.com>
	 <1345222134.29668.63.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	vivek@us.ibm.com, sri@us.ibm.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:47221 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755811Ab2HQQ6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 12:58:20 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Fri, 17 Aug 2012 12:58:18 -0400
In-Reply-To: <1345222134.29668.63.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-17 at 18:48 +0200, Peter Zijlstra wrote:
> On Fri, 2012-08-17 at 08:39 -0700, Shirley Ma wrote:
> 
> > Hello Ingo, Peter,
> >         Have you had chance to review below patch?
> 
> Well no of course not, nobody CC'ed us..
> 
> Your patch submission sucks, you split the changelog and the actual
> patch into two different emails.
> 
> It doesn't mention who would be calling this and how often. Nor does
> it
> seem to explain where the cpumask arguments come from.
> 
> Please try again.

Thanks for your comments. I must be spoiled by net-dev maintainers. I
used to submit the patch this way thought my linux email in the past
many years. So I need to reply on the changelog for the actual patch? I
hope I won't make any more suck submissions again.

I will try to explain more details why this API needs to be exported.

Thanks again.
Shirley
