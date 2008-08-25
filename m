From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] bnx2x: Initialization structure
Date: Mon, 25 Aug 2008 15:25:17 -0700 (PDT)
Message-ID: <20080825.152517.50052684.davem@davemloft.net>
References: <1219674289.19456.31.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gertner@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbYHYWZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:25:21 -0400
In-Reply-To: <1219674289.19456.31.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 25 Aug 2008 17:24:49 +0300

> The TPA initialization is part of the FW internal memory initialization
> and so it is moved to the appropriate function
> 
> Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, but this is really more of a cleanup than a bug
fix (at least as per the commit message and what I can
see in the patch) so it really isn't something that should
be submitted outside of the merge window.

Please be mindful of this in the future and only send real
true and clear bug fixes outside of the merge window.

Thanks.
