From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bnx2x: Don't set netdev->trans_start
Date: Wed, 18 Nov 2009 05:06:41 -0800 (PST)
Message-ID: <20091118.050641.161953283.davem@davemloft.net>
References: <1258474595.32030.1.camel@lb-tlvb-vladz.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753634AbZKRNGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 08:06:24 -0500
In-Reply-To: <1258474595.32030.1.camel@lb-tlvb-vladz.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Tue, 17 Nov 2009 18:16:35 +0200

> Setting dev->trans_start caused spurious watchdog warnings.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
