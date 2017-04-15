From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] ipset: remove unused function
 __ip_set_get_netlink
Date: Sat, 15 Apr 2017 10:45:50 +0200
Message-ID: <20170415084550.GA1284@salvia>
References: <20170410195237.19909-1-aconole@bytheb.org>
 <20170413232842.GC7721@salvia>
 <alpine.DEB.2.11.1704141612410.5084@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Aaron Conole <aconole@bytheb.org>,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56312 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752091AbdDOIqC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Apr 2017 04:46:02 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4D58AE045C
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 10:45:57 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3E2D3DA391
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 10:45:57 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A1AC5DA390
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 10:45:53 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1704141612410.5084@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 04:15:41PM +0200, Jozsef Kadlecsik wrote:
> Hi Pablo,
> 
> On Fri, 14 Apr 2017, Pablo Neira Ayuso wrote:
> 
> > On Mon, Apr 10, 2017 at 03:52:37PM -0400, Aaron Conole wrote:
> > > There are no in-tree callers.
> > 
> > @Jozsef, let me know if I should just take this to save you a pull
> > request.
> 
> Just take it, thank you.
> 
> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Applied, thanks Jozsef.
