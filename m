From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: remove duplicate call to the pci_set_drvdata
Date: Sat, 07 Jul 2012 16:16:24 -0700 (PDT)
Message-ID: <20120707.161624.852350945325551955.davem@davemloft.net>
References: <1341641255-26429-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab2GGXQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 19:16:25 -0400
In-Reply-To: <1341641255-26429-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Sat,  7 Jul 2012 11:37:35 +0530

> pci_set_drvdata is called twice at the remove path of driver,
> call it once.
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Applied, thanks.
