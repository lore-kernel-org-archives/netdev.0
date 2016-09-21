From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] ipvlan: Fix dependency issue
Date: Tue, 20 Sep 2016 22:56:46 -0400 (EDT)
Message-ID: <20160920.225646.988328823086222754.davem@davemloft.net>
References: <1474318589-6452-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754738AbcIUC4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:56:49 -0400
In-Reply-To: <1474318589-6452-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Mon, 19 Sep 2016 13:56:29 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> kbuild-build-bot reported that if NETFILTER is not selected, the
> build fails pointing to netfilter symbols.
> 
> Fixes: 4fbae7d83c98 ("ipvlan: Introduce l3s mode")
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
