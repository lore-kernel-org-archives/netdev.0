From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: AER revised
Date: Wed, 20 Mar 2013 13:27:59 -0400 (EDT)
Message-ID: <20130320.132759.1173007387852870582.davem@davemloft.net>
References: <1363792888-29392-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab3CTR2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:28:02 -0400
In-Reply-To: <1363792888-29392-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 20 Mar 2013 17:21:28 +0200

> Revised bnx2x implementation of PCI Express Advanced Error Recovery -
> stop and free driver resources according to the AER flow (instead of the
> currently implemented `hope-for-the-best' release approach), and do not make
> any assumptions on the HW state after slot reset.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied, thanks.
