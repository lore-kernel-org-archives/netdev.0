From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] netfilter: netfilter update
Date: Thu, 13 May 2010 19:07:31 -0700 (PDT)
Message-ID: <20100513.190731.258096719.davem@davemloft.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752201Ab0ENCHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 22:07:24 -0400
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Thu, 13 May 2010 18:16:13 +0200

> following is a second netfilter update, containing:
> 
> - a compilation fix for ip_tables with CONFIG_NETFILTER_DEBUG=y, from Jan
> 
> - a fix for an invalid return value in the multiport match introduced in
>   the last series, from Jan
> 
> - patches to combine the match and target parameters into a common structure,
>   from Jan
> 
> - Bart's patch to fix the NULL pointer dereference in bridge netfilter
>   reported by Stephen
> 
> - minor cleanups and improvements from Jan, Stephen and Joe
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Pulled, thanks Patrick.
