From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 3/5] netlink: add NLM_F_NONREC flag for deletion
 requests
Date: Mon, 4 Sep 2017 02:22:00 +0200
Message-ID: <20170904002200.GA16380@salvia>
References: <1504475761-11454-1-git-send-email-pablo@netfilter.org>
 <20170903.171418.350656093498203113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:41631 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753046AbdIDAWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 20:22:32 -0400
Content-Disposition: inline
In-Reply-To: <20170903.171418.350656093498203113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 03, 2017 at 05:14:18PM -0700, David Miller wrote:
> 
> I only see patches 3, 4, and 5 of this series.
> 
> If this is meant for net-next inclusion, you'll have to submit it such that
> I see the entire series on netdev and thus in patchwork.

I'm posting this new NLM_F_NONREC for acknowledgment, if possible. I
have a few more patches that follow up so I can take them through
nf-next in the next batch.

But I can just re-send this through your net-next tree, as you prefer.
