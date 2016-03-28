From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] Netfilter fixes for net
Date: Mon, 28 Mar 2016 15:43:56 -0400 (EDT)
Message-ID: <20160328.154356.1722755920521134341.davem@davemloft.net>
References: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 28 Mar 2016 19:57:53 +0200

> The following patchset contains Netfilter fixes for you net tree,
> they are:
 ...
> This batch comes with four patches to validate x_tables blobs coming
> from userspace. CONFIG_USERNS exposes the x_tables interface to
> unpriviledged users and to be honest this interface never received the
> attention for this move away from the CAP_NET_ADMIN domain. Florian is
> working on another round with more patches with more sanity checks, so
> expect a bit more Netfilter fixes in this development cycle than usual.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Looks good, pulled, thanks Pablo!
