From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: implement ndo_set_vf_rate()
Date: Tue, 06 Jun 2017 15:17:26 -0400 (EDT)
Message-ID: <20170606.151726.2250862189923579543.davem@davemloft.net>
References: <1496667860-11703-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, kumaras@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdFFTRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 15:17:32 -0400
In-Reply-To: <1496667860-11703-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Mon,  5 Jun 2017 18:34:20 +0530

> Implement ndo_set_vf_rate() for mgmt interface to support rate-limiting
> of VF traffic using 'ip' command.
> 
> Based on the original work of Kumar Sanghvi <kumaras@chelsio.com>
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied to net-next, thanks Ganesh.
