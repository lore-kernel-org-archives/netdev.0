From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/8] net/wan/fsl_ucc_hdlc: fix incorrect
 memory allocation
Date: Thu, 18 May 2017 10:29:31 -0400 (EDT)
Message-ID: <20170518.102931.1618826135082382880.davem@davemloft.net>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
        <20170517152439.8817-4-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qiang.zhao@nxp.com
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755070AbdERO3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:29:32 -0400
In-Reply-To: <20170517152439.8817-4-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Wed, 17 May 2017 17:24:35 +0200

> We need space for the struct qe_bd and not for a pointer to this struct.
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>

Applied.
