From: Florian Westphal <fw@strlen.de>
Subject: Re: net-next tree broken with CONFIG_NETFILTER_INGRESS=n
Date: Wed, 5 Oct 2016 10:51:45 +0200
Message-ID: <20161005085145.GA10576@breakpoint.cc>
References: <E3004E95-F774-457E-9BA8-FA29A72BE035@holtmann.org>
 <57588F77-89EA-4BAF-8B11-E45D22B49968@holtmann.org>
 <20161005.040137.1214181921027379179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel@holtmann.org, netdev@vger.kernel.org, aconole@bytheb.org,
        fw@strlen.de, pablo@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45790 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752105AbcJEIwR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 04:52:17 -0400
Content-Disposition: inline
In-Reply-To: <20161005.040137.1214181921027379179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Marcel Holtmann <marcel@holtmann.org>
> Date: Wed, 5 Oct 2016 09:48:42 +0200
> 
> > I really wonder what is going on here. Normally if you break the
> > build, you fix it. However it seems nobody really cares enough. If I
> > am not mistaken, then this patch broke it:
> 
> The people who can work on and merge the fix are travelling and
> conferencing in Tokyo right now, that's why this wasn't fixed
> instantaneously.

Seems the fix is rotting in nf-next....
