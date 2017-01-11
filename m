From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: pdiag_put_ring() should return
 TX_RING info for TPACKET_V3
Date: Tue, 10 Jan 2017 21:03:07 -0500 (EST)
Message-ID: <20170110.210307.1436503699268187499.davem@davemloft.net>
References: <cover.1484060892.git.sowmini.varadhan@oracle.com>
        <b1ae12eaef34ce413e2dc3bc5075a3c0198d7ad1.1484060892.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, willemb@google.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935782AbdAKCDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:03:09 -0500
In-Reply-To: <b1ae12eaef34ce413e2dc3bc5075a3c0198d7ad1.1484060892.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 10 Jan 2017 07:47:15 -0800

> Commit 7f953ab2ba46 ("af_packet: TX_RING support for TPACKET_V3")
> now makes it possible to use TX_RING with TPACKET_V3, so make the
> the relevant information available via 'ss -e -a --packet'
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied, thanks.
