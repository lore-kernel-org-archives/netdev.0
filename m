From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter fix for 3.6-rc7
Date: Thu, 27 Sep 2012 13:16:52 -0400 (EDT)
Message-ID: <20120927.131652.1225627823442004748.davem@davemloft.net>
References: <1348616051-5694-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348616051-5694-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Wed, 26 Sep 2012 01:34:10 +0200

> If time allows, I'd appreciate if you can take the following fix
> for the xt_limit match.
> 
> As Jan indicates, random things may occur while using the xt_limit
> match due to use of uninitialized memory.
> 
> You can pull this change from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks.
