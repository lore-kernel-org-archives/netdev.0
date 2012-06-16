From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] netfilter updates for net-next (upcoming 3.6),
 batch 2
Date: Sat, 16 Jun 2012 15:24:23 -0700 (PDT)
Message-ID: <20120616.152423.1487928117133764164.davem@davemloft.net>
References: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Sat, 16 Jun 2012 17:49:49 +0200

> This is the second batch of Netfilter updates for net-next. It contains the
> kernel changes for the new user-space connection tracking helper
> infrastructure.
> 
> More details on this infrastructure are provides here:
> http://lwn.net/Articles/500196/
> 
> Still, I plan to provide some official documentation through the
> conntrack-tools user manual on how to setup user-space utilities for this.
> So far, it provides two helper in user-space, one for NFSv3 and another for
> Oracle/SQLnet/TNS. Yet in my TODO list.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Pulled, thanks Pablo.
