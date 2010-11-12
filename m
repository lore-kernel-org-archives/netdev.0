From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter: netfilter fixes
Date: Fri, 12 Nov 2010 11:07:04 -0800 (PST)
Message-ID: <20101112.110704.71107258.davem@davemloft.net>
References: <1289575172-7272-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289575172-7272-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: kaber@trash.net
Date: Fri, 12 Nov 2010 16:19:30 +0100

> Hi Dave,
> 
> The following two patches fix some netfilter bugs:
> 
> - missing parentheses in NF_HOOK_COND, breaking error propagation for
>   dropped packets. From Eric Paris.
> 
> - incorrect checking for overlapping fragments in IPv6 conntrack
>   reassembly. From Shan Wei
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Pulled, thanks Patrick.
