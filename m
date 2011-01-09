From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/5] bnx2x: registers dump fixes
Date: Sun, 09 Jan 2011 15:49:45 -0800 (PST)
Message-ID: <20110109.154945.258114156.davem@davemloft.net>
References: <1294575604.31551.16.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753144Ab1AIXtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 18:49:14 -0500
In-Reply-To: <1294575604.31551.16.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 9 Jan 2011 14:20:04 +0200

> Fixes in registers dump:
>         - Properly calculate dump length for 57712.
>         - Prevent HW blocks parity attentions when dumping registers in order to
> prevent false parity errors handling.
>         - Update the bnx2x_dump.h file: old one had a few bugs that could cause
> fatal HW error as a result of a registers dump.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
