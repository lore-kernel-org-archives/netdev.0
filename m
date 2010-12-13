From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] bnx2x: FCoE support
Date: Mon, 13 Dec 2010 09:49:07 -0800 (PST)
Message-ID: <20101213.094907.226756740.davem@davemloft.net>
References: <1292255013.631.48.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com,
	shmulikr@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58988
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757626Ab0LMRsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 12:48:39 -0500
In-Reply-To: <1292255013.631.48.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Mon, 13 Dec 2010 17:43:33 +0200

> Hello Dave,
> 
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

Don't do this with the firmware files, at least email me a copy
so I don't have to go to a special web sit to get the patch.

You've never done it this special way before, you've always at
least email'd me a copy.  That was the right thing to do, what
in the world made you do things differently this time? :-/

Ugh...
