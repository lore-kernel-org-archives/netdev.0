From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: preserve type of dst_port parm for
 encap_bypass_if_local()
Date: Fri, 20 Jan 2017 12:12:27 -0500 (EST)
Message-ID: <20170120.121227.868633873599720363.davem@davemloft.net>
References: <1484771097-5692-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbdATRMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:12:34 -0500
In-Reply-To: <1484771097-5692-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Wed, 18 Jan 2017 15:24:57 -0500

> Eliminate sparse warning by maintaining type of dst_port
> as __be16.
> 
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied.
