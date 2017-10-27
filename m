From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] tcp: move 14 sysctls to namespaces
Date: Fri, 27 Oct 2017 13:46:18 +0900 (KST)
Message-ID: <20171027.134618.1897786547133417592.davem@davemloft.net>
References: <20171026233526.6155-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdJ0EqX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:46:23 -0400
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 26 Oct 2017 16:35:11 -0700

> Ideally all TCP sysctls should be per netns.
> This patch series takes care of 14 of sysctls.
> More to come later.

The tcp-fack patch doesn't apply cleanly, please respin.

Thank you.
