From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] sk_nulls_next_rcu
Date: Tue, 1 Dec 2009 02:32:47 +0200
Message-ID: <200912010232.47308.opurdila@ixiacom.com>
References: <200912010219.29340.opurdila@ixiacom.com> <20091130.162454.119309341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13503 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753148AbZLAAfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 19:35:54 -0500
In-Reply-To: <20091130.162454.119309341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 December 2009 02:24:54 you wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Tue, 1 Dec 2009 02:19:29 +0200
> 
> > I am trying to convert the LLC code to RCU, and it appears that for proc
> > support a sk_nulls_next_rcu would be required.
> >
> > Is this the wrong way to do it, or is it that nobody need it yet?
> 
> I think simply nobody needed it yet.
> 
> Eric, please take a look at Octavian's patch, thanks!
> 

I will send a patch series later with several LLC enhancements, no need to 
look over the LLC bits yet - its not all done yet. I'll CC Eric on the RCU 
parts :)
