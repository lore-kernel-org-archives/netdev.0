From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/03: netfilter fixes
Date: Thu, 16 Apr 2009 16:33:10 -0700 (PDT)
Message-ID: <20090416.163310.130659157.davem@davemloft.net>
References: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 16 Apr 2009 19:16:22 +0200 (MEST)

> the following three patches fix two netfilter bugs introduced during the merge
> window and re-add support for a feature that accidentally got dropped with the
> SAME target removal:
> 
> - a missing list initialization of the nf_log logger lists
> 
> - a missing conversion to use the hlist_nulls list function in connection tracking
>   helper unregistration
> 
> - support for persistent multi-range NAT mappings
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Pulled, thanks a lot!
