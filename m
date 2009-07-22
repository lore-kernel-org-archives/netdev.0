From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Rework mdio-ofgpio driver to use of_mdio
 infrastructure
Date: Wed, 22 Jul 2009 09:40:59 -0700 (PDT)
Message-ID: <20090722.094059.113003489.davem@davemloft.net>
References: <4A66400F.3090309@elphinstone.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: mware@elphinstone.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753530AbZGVQkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 12:40:53 -0400
In-Reply-To: <4A66400F.3090309@elphinstone.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Ware <mware@elphinstone.net>
Date: Wed, 22 Jul 2009 08:24:15 +1000

> Changes to the fs_enet driver
> (aa73832c5a80d6c52c69b18af858d88fa595dd3c) cause kernel crashes when
> using the mdio-ofgpio driver.
> 
> This patch replicates similar changes made to the fs_enet mii-bitbang
> drivers.  It has been tested on a custom mpc8280 based board using an
> NFS mounted root.
> 
> Signed-off-by: Mark Ware <mware@elphinstone.net>
> Acked-by: Grant Likely <grant.likely@secretlab.ca>

Your email client has massively corrupted this patch, I even tried
to fix it up but it's so bad that I just gave up half-way through.

Please use an attachment or whatever is necessary to get this
patch submitted cleanly and without it getting damaged.  Read:

linux/Documentation/email-clients.txt

for tips.

Thanks.
