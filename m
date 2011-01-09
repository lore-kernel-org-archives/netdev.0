From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/5] bnx2x: Don't prevent RSS configuration in
 INT#x and MSI interrupt modes.
Date: Sun, 09 Jan 2011 15:49:41 -0800 (PST)
Message-ID: <20110109.154941.212684332.davem@davemloft.net>
References: <1294575580.31551.12.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752071Ab1AIXtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 18:49:09 -0500
In-Reply-To: <1294575580.31551.12.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 9 Jan 2011 14:19:40 +0200

> Don't prevent RSS configuration in INT#x and MSI interrupt modes. Otherwise
> Rx hash key won't be available.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
