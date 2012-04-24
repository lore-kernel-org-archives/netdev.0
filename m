From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bnx2x: use FW 7.2.51 and add afex support
Date: Mon, 23 Apr 2012 22:34:31 -0400 (EDT)
Message-ID: <20120423.223431.1645975348493622347.davem@davemloft.net>
References: <1335186273.14229.25.camel@lb-tlvb-barak.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: barak@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756368Ab2DXCef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:34:35 -0400
In-Reply-To: <1335186273.14229.25.camel@lb-tlvb-barak.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Barak Witkowski" <barak@broadcom.com>
Date: Mon, 23 Apr 2012 16:04:33 +0300

> This patch utilize FW 7.2.51 that was recently added to the linux-firmware tree.
> 
> The main feature of this new FW is support of the AFEX multi-function protocol.
> Supporting the afex protocol requires many changes in the driver, but all of
> them are required together in order to compile and make the feature operational.
> Breaking the afex patch into smaller chunks did not seem to increase readability
> to me.

All applied, thanks.
