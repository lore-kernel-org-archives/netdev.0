From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/34]bnx2x: Reset HW before use
Date: Sat, 17 Jan 2009 23:17:06 -0800 (PST)
Message-ID: <20090117.231706.48278724.davem@davemloft.net>
References: <1231951416.11301.139.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45803
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756077AbZARHRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:17:05 -0500
In-Reply-To: <1231951416.11301.139.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:36 +0200

> To avoid complications, make sure that the HW is in reset (as it should be)
> before trying to take it out of reset. In normal flows, the HW is indeed in rest
> so this should have no effect
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
