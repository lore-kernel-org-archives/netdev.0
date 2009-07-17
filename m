From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/03: netfilter fixes
Date: Thu, 16 Jul 2009 17:37:45 -0700 (PDT)
Message-ID: <20090716.173745.187759558.davem@davemloft.net>
References: <20090716122638.23343.77832.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090716122638.23343.77832.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 16 Jul 2009 14:26:44 +0200 (MEST)

> following are two netfilter fixes for 2.6.31 and a MAINTAINERS update:
> 
> - a fix for the nf_conntrack_alloc() race from Eric
> - a fix for incorrect invocation of nf_log_packet() in the new osf match
> - a patch to add my netfilter git tree to MAINTAINERS
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks a lot Patrick!
