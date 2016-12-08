From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: slicoss: use module_pci_driver()
Date: Thu, 08 Dec 2016 13:01:43 -0500 (EST)
Message-ID: <20161208.130143.624727321836971316.davem@davemloft.net>
References: <20161207134330.8829-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LinoSanfilippo@gmx.de, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35744 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbcLHSBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:01:45 -0500
In-Reply-To: <20161207134330.8829-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  7 Dec 2016 14:43:30 +0100

> Use module_pci_driver() to get rid of some boilerplate code.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
