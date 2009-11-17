From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Tue, 17 Nov 2009 04:08:58 -0800 (PST)
Message-ID: <20091117.040858.208512119.davem@davemloft.net>
References: <1258387558.30637.77.camel@lb-tlvb-vladz.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38129
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755131AbZKQMIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:08:42 -0500
In-Reply-To: <1258387558.30637.77.camel@lb-tlvb-vladz.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Mon, 16 Nov 2009 18:05:58 +0200

> Put Tx and Rx DPC to be handled in the NAPI:
>   - Saves status blocks.
>   - Moves the Tx work from hardIRQ to NAPI.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thank you.
