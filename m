From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: extract the function to compute
 delivery rate
Date: Mon, 31 Jul 2017 17:26:29 -0700 (PDT)
Message-ID: <20170731.172629.2112953749377912432.davem@davemloft.net>
References: <20170728172821.102562-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, soheil@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48312 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdHAA0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:26:30 -0400
In-Reply-To: <20170728172821.102562-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 28 Jul 2017 10:28:20 -0700

> From: Wei Wang <weiwan@google.com>
> 
> Refactor the code to extract the function to compute delivery rate.
> This function will be used in later commit.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Applied.
