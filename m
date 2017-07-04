From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] net: reflect mark on tcp syn ack packets
Date: Tue, 04 Jul 2017 01:46:43 -0700 (PDT)
Message-ID: <20170704.014643.1308328865535236606.davem@davemloft.net>
References: <1499089910-20034-1-git-send-email-jhs@emojatatu.com>
        <1499089910-20034-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46220 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751879AbdGDIqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 04:46:46 -0400
In-Reply-To: <1499089910-20034-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon,  3 Jul 2017 09:51:50 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> SYN-ACK responses on a server in response to a SYN from a client
> did not get the injected skb mark that was tagged on the SYN packet.
> 
> Fixes: 84f39b08d786 ("net: support marking accepting TCP sockets")
> Reviewed-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks Jamal.
