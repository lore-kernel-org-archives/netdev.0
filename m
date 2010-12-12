From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/3] bnx2x: Fixed a compilation warning
Date: Sun, 12 Dec 2010 15:03:53 -0800 (PST)
Message-ID: <20101212.150353.15243024.davem@davemloft.net>
References: <1292163132.20811.161.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752726Ab0LLXDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 18:03:25 -0500
In-Reply-To: <1292163132.20811.161.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 12 Dec 2010 16:12:12 +0200

> bnx2x_src_init_t2() is used only when BCM_CNIC is defined.
> So, to avoid a compilation warning, we won't define it unless
> BCM_CNIC is defined.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
