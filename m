From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v1 1/1] l2tp: Use existing macros instead of literal
 number
Date: Fri, 19 Aug 2016 20:28:54 +0200
Message-ID: <20160819182854.wdgnz77h2pins2c5@alphalink.fr>
References: <1471600526-22584-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, davem@davemloft.net,
        philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:59794 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753665AbcHSS37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 14:29:59 -0400
Content-Disposition: inline
In-Reply-To: <1471600526-22584-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 05:55:26PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> 1. Use PPP_ALLSTATIONS/PPP_UI instead of literal 0xff/0x03;
> 2. Use one static const global fixed_ppphdr instead of two same
> static variable ppph in two different functions;
> 3. Use SEND_SHUTDOWN instead of literal 2;
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v1: Initial patch
> 
v1 again?

BTW, no need to number your patch for a single patch series.
But you have to tell which tree is the series for.

So instead of [PATCH v1 1/1], you should send [PATCH v2 net-next].
