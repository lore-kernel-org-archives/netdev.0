From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/packet: remove unneeded declaraion of
 tpacket_snd().
Date: Sat, 10 Jun 2017 16:15:34 -0400 (EDT)
Message-ID: <20170610.161534.909504089321231218.davem@davemloft.net>
References: <1497054168-5444-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdFJUPg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:15:36 -0400
In-Reply-To: <1497054168-5444-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Sat, 10 Jun 2017 03:22:48 +0300

> This patch removes unneeded forward declaration of tpacket_snd()
> in net/packet/af_packet.c.
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied, thanks Rami.
