From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vrf: Fix setting NLM_F_EXCL flag when adding
 l3mdev rule
Date: Mon, 17 Apr 2017 13:28:29 -0400 (EDT)
Message-ID: <20170417.132829.1427802343081416162.davem@davemloft.net>
References: <20170413165715.10365-1-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752223AbdDQR2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:28:31 -0400
In-Reply-To: <20170413165715.10365-1-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 13 Apr 2017 10:57:15 -0600

> Only need 1 l3mdev FIB rule. Fix setting NLM_F_EXCL in the nlmsghdr.
> 
> Fixes: 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
