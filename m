From: David Miller <davem@davemloft.net>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Thu, 07 Sep 2017 19:13:24 -0700 (PDT)
Message-ID: <20170907.191324.852949594923852324.davem@davemloft.net>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, lorenzo@google.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751780AbdIHCNZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 22:13:25 -0400
In-Reply-To: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Thu, 07 Sep 2017 18:52:02 -0600

> [ 3489.194392]  __ion_alloc+0x180/0x988

I do not see the __ion_alloc function in my tree.
