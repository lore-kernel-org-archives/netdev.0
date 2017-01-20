From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] csum: eliminate sparse warning in
 remcsum_unadjust()
Date: Fri, 20 Jan 2017 12:12:33 -0500 (EST)
Message-ID: <20170120.121233.96961093171686636.davem@davemloft.net>
References: <1484770496-3401-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752497AbdATRMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:12:34 -0500
In-Reply-To: <1484770496-3401-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Wed, 18 Jan 2017 15:14:56 -0500

> Cast second parameter of csum_sub() from __sum16 to __wsum.
> 
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied.
