From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] l2tp: fix error handling of PPPoL2TP socket
 options
Date: Sat, 08 Apr 2017 08:29:32 -0700 (PDT)
Message-ID: <20170408.082932.1467133884252968987.davem@davemloft.net>
References: <cover.1491495941.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40832 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752085AbdDHP3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:29:34 -0400
In-Reply-To: <cover.1491495941.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 6 Apr 2017 18:31:18 +0200

> Fix pppol2tp_[gs]etsockopt() so that they don't ignore errors returned
> by their helper functions.

Series applied, thanks.
