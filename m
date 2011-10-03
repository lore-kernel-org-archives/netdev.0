From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Add 60 second delay to allow FAT
 dump completion on recovery from EEH
Date: Mon, 03 Oct 2011 12:15:04 -0400 (EDT)
Message-ID: <20111003.121504.1168096803076705686.davem@davemloft.net>
References: <5bb8f639-e754-4e08-8b7b-9830a57e4826@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab1JCQPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 12:15:09 -0400
In-Reply-To: <5bb8f639-e754-4e08-8b7b-9830a57e4826@exht2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@Emulex.Com>
Date: Mon, 3 Oct 2011 23:40:57 +0530

> Add 60s delay before timeout on polling Bit 31 so that FAT dump can
> complete when reset occurs.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
