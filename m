From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] bnx2x: HW lock timeout
Date: Mon, 25 Aug 2008 15:23:38 -0700 (PDT)
Message-ID: <20080825.152338.21181143.davem@davemloft.net>
References: <1219674281.19456.30.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52493
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753243AbYHYWXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:23:42 -0400
In-Reply-To: <1219674281.19456.30.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 25 Aug 2008 17:24:41 +0300

> Increasing the lock timeout to 5 seconds instead of 1 second to minimize
> the chance of failures due to timeout
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
