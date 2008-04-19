From: David Miller <davem@davemloft.net>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on
 latest -git
Date: Sat, 19 Apr 2008 04:10:34 -0700 (PDT)
Message-ID: <20080419.041034.33055901.davem@davemloft.net>
References: <20080419100034.GA9475@elte.hu>
	<20080419.030736.168169087.davem@davemloft.net>
	<20080419104152.GB13599@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080419104152.GB13599@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 19 Apr 2008 12:41:52 +0200

> thanks David, this solves the build failure here.
> 
> Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks for testing.

I guess if you had been able to reply to the merge request
thread, this would have been fixed faster, sorry about that.
