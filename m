From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter updates for net tree
Date: Fri, 24 Feb 2012 17:42:55 -0500 (EST)
Message-ID: <20120224.174255.1070045757228634346.davem@davemloft.net>
References: <1330123104-3953-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330123104-3953-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 24 Feb 2012 23:38:22 +0100

> This patchset revert the previous fix for ctnetlink soft lockup when
> the conntrack table is full. There was a race condition between the
> possible creation of the conntrack by one packet and ctnetlink itself.
> Then it follows the new fix which is complete.
> 
> I'm sorry for puzzling, I'll put more care on this next time.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/net master

It happens.

Next time you can skip the revert and just add in a relative fix.
