From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/15] solos-pci: use permission-specific DEVICE_ATTR
 variants
Date: Mon, 31 Oct 2016 15:32:39 -0400 (EDT)
Message-ID: <20161031.153239.689239951085959593.davem@davemloft.net>
References: <1477769829-22230-1-git-send-email-Julia.Lawall@lip6.fr>
        <1477769829-22230-16-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, kernel-janitors@vger.kernel.org,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945642AbcJaTcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:32:41 -0400
In-Reply-To: <1477769829-22230-16-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 29 Oct 2016 21:37:09 +0200

> Use DEVICE_ATTR_RW for read-write attributes.  This simplifies the
> source code, improves readbility, and reduces the chance of
> inconsistencies.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied to net-next.
