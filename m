From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter fixes for net
Date: Mon, 09 Dec 2013 20:43:59 -0500 (EST)
Message-ID: <20131209.204359.870819413394556150.davem@davemloft.net>
References: <1386458010-4615-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1386458010-4615-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun,  8 Dec 2013 00:13:27 +0100

> The following patchset contains three Netfilter fixes for your net tree,
> they are:
> 
> * fix incorrect comparison in the new netnet hash ipset type, from
>   Dave Jones.
> 
> * fix splat in hashlimit due to missing removal of the content of its
>   proc entry in netnamespaces, from Sergey Popovich.
> 
> * fix missing rule flushing operation by table in nf_tables. Table
>   flushing was already discussed back in October but this got lost and
>   no patch has hit the tree to address this issue so far, from me.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo.
