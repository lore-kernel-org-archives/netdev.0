From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] bnx2x: FCoE support
Date: Thu, 16 Dec 2010 11:43:33 -0800 (PST)
Message-ID: <20101216.114333.112592773.davem@davemloft.net>
References: <1292255013.631.48.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com,
	shmulikr@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49131
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066Ab0LPTnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 14:43:06 -0500
In-Reply-To: <1292255013.631.48.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Mon, 13 Dec 2010 17:43:33 +0200

> This patch-series adds FCoE support to 57712 HW. It provides
> required intefaces for upper-level driver (CNIC) and handles
> FCoE related HW/FW initialization and flows.
> 
> Since the FW files are too big (patches 6 and 8) and will not 
> pass the mailing list, it is also located at:
> http://linux.broadcom.com/eilong/1.62.00-2
> 
> It's a second attempt to submit this patch series after fixing
> a Tx hash distribution fairness.

Applied.
