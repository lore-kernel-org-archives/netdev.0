From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/34]bnx2x: Fixing the doorbell size
Date: Wed, 14 Jan 2009 21:28:27 -0800 (PST)
Message-ID: <20090114.212827.117436603.davem@davemloft.net>
References: <1231951397.11301.133.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbZAOF20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:28:26 -0500
In-Reply-To: <1231951397.11301.133.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:17 +0200

> The size of the doorbell is 4KB, this bug become visible when using
> more than 8 queues
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
