From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: fix a power state test
Date: Sun, 02 Jun 2013 21:40:05 -0700 (PDT)
Message-ID: <20130602.214005.1774370170369806654.davem@davemloft.net>
References: <1370163746-30745-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	kernel-janitors@vger.kernel.org, ariele@broadcom.com,
	eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab3FCEkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 00:40:06 -0400
In-Reply-To: <1370163746-30745-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 2 Jun 2013 12:02:26 +0300

> If PCIe supports PM capabilities, bnx2x will always claim eeprom is accessible
> as PCI_D0 is zero.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
