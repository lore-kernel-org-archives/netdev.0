From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v5 net-next] l2tp: Refactor the codes with existing
 macros instead of literal number
Date: Mon, 22 Aug 2016 17:02:08 +0200
Message-ID: <20160822150208.vtthd4ghhudv66lp@alphalink.fr>
References: <1471877402-31384-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, philipp@redfish-solutions.com,
        davem@davemloft.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:45101 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754748AbcHVPDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 11:03:03 -0400
Content-Disposition: inline
In-Reply-To: <1471877402-31384-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 10:50:02PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
> 0x03, and 2 separately.
> 

Acked-by: Guillaume Nault <g.nault@alphalink.fr>
