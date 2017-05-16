From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] udp: scalability improvements
Date: Tue, 16 May 2017 15:41:49 -0400 (EDT)
Message-ID: <20170516.154149.199666340821000197.davem@davemloft.net>
References: <cover.1494881617.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52862 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdEPTlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:41:52 -0400
In-Reply-To: <cover.1494881617.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 16 May 2017 11:20:12 +0200

> This patch series implement an idea suggested by Eric Dumazet to
> reduce the contention of the udp sk_receive_queue lock when the socket is
> under flood.

Series applied, thanks a lot.
