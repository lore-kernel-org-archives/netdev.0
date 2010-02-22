From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] b44: use netdev_alloc_skb instead of dev_alloc_skb
Date: Mon, 22 Feb 2010 15:46:45 -0800 (PST)
Message-ID: <20100222.154645.12890057.davem@davemloft.net>
References: <1266699326-1541-1-git-send-email-hauke@hauke-m.de>
	<1266699326-1541-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47070
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751186Ab0BVXq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:46:27 -0500
In-Reply-To: <1266699326-1541-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat, 20 Feb 2010 21:55:26 +0100

> The conversion in bf0dcbd929faf036f1a4f2918090344d0e249cf5 missed the
> new allocation in b44_rx.
> This patch was used in OpenWRT for a long time.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied.
