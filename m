From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix ndo_features_check/ndo_fix_features comment
 ordering
Date: Wed, 01 Feb 2017 12:11:04 -0500 (EST)
Message-ID: <20170201.121104.916362134796358988.davem@davemloft.net>
References: <20170201000313.11868-1-dmichail@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: dmichail@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39752 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752764AbdBARLF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:11:05 -0500
In-Reply-To: <20170201000313.11868-1-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dmichail@google.com>
Date: Tue, 31 Jan 2017 16:03:13 -0800

> Commit cdba756f5803a2 ("net: move ndo_features_check() close to
> ndo_start_xmit()") inadvertently moved the doc comment for
> .ndo_fix_features instead of .ndo_features_check. Fix the comment
> ordering.
> 
> Fixes: cdba756f5803a2 ("net: move ndo_features_check() close to ndo_start_xmit()")
> Signed-off-by: Dimitris Michailidis <dmichail@google.com>

Applied, thank you.
