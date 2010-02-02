From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/02: netfilter fixes
Date: Tue, 02 Feb 2010 09:05:57 -0800 (PST)
Message-ID: <20100202.090557.263985674.davem@davemloft.net>
References: <20100202162736.24867.67227.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100202162736.24867.67227.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  2 Feb 2010 17:27:37 +0100 (MET)

> the following two patches fix two bugs in netfilter:
> 
> - an off-by-one in SIP conntrack short header parsing, causing mismatches
>   with UAs not inserting a space after the colon
> 
> - a missing initialization in ctnetlink when dumping an expectation mask,
>   causing an invalid layer 4 protocol number to be used
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks Patrick.
