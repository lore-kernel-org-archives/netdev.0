From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] net/wan/fsl_ucc_hdlc: cleanup debug traces
Date: Thu, 18 May 2017 10:29:09 -0400 (EDT)
Message-ID: <20170518.102909.1182288374811078961.davem@davemloft.net>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qiang.zhao@nxp.com
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756089AbdERO3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:29:12 -0400
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Wed, 17 May 2017 17:24:32 +0200

> Some of the tracing seems to be remaining traces for basic driver
> development. They can be removed now, as they cause noisy printouts.
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
> Cc: Zhao Qiang <qiang.zhao@nxp.com>

Applied.
