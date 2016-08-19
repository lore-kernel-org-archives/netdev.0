From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH 1/1] l2tp: Fix the connect status check in
 pppol2tp_getname
Date: Fri, 19 Aug 2016 21:24:05 +0200
Message-ID: <20160819192405.qusfewm6siyejpmf@alphalink.fr>
References: <1471584983-18774-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, davem@davemloft.net,
        philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60897 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753990AbcHSTYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 15:24:13 -0400
Content-Disposition: inline
In-Reply-To: <1471584983-18774-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 01:36:23PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> The sk->sk_state is bits flag, so need use bit operation check
> instead of value check.
> 

Tested-by: Guillaume Nault <g.nault@alphalink.fr>
