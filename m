From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v8 0/3] net: core: Two Helper function about
 socket information
Date: Thu, 23 Mar 2017 17:03:00 -0700 (PDT)
Message-ID: <20170323.170300.1967668044871774699.davem@davemloft.net>
References: <1490228856-4546-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        lorenzo@google.com, willemb@google.com, fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdCXADC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 20:03:02 -0400
In-Reply-To: <1490228856-4546-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Wed, 22 Mar 2017 17:27:33 -0700

> Introduce two eBpf helper function to get the socket cookie and
> socket uid for each packet. The helper function is useful when
> the *sk field inside sk_buff is not empty. These helper functions
> can be used on socket and uid based traffic monitoring programs.

Series applied, thanks.
