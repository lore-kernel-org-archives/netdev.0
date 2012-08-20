From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netfilter fixes for 3.6-rc
Date: Mon, 20 Aug 2012 02:45:04 -0700 (PDT)
Message-ID: <20120820.024504.634595271117672814.davem@davemloft.net>
References: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 17 Aug 2012 16:09:28 +0200

> The following five patches contain fixes for 3.6-rc, they are:
> 
> * Two fixes for message parsing in the SIP conntrack helper, from
>   Patrick McHardy.
> 
> * One fix for the SIP helper introduced in the user-space cthelper
>   infrastructure, from Patrick McHardy.
> 
> * fix missing appropriate locking while modifying one conntrack entry
>   from the nfqueue integration code, from myself.
> 
> * fix possible access to uninitiliazed timer in the nf_conntrack
>   expectation infrastructure, from myself.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf

Pulled, thanks Pablo.
