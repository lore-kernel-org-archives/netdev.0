From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Mon, 18 Mar 2013 13:13:18 -0400 (EDT)
Message-ID: <20130318.131318.138158829629301794.davem@davemloft.net>
References: <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
	<CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
	<1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, eric.dumazet@gmail.com, dmitry@broadcom.com,
	netdev@vger.kernel.org, yuvalmin@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab3CRRNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 13:13:21 -0400
In-Reply-To: <1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 18 Mar 2013 12:06:22 +0200

> Maciej - thanks for the detailed information. You are right - it has
> nothing to do with the HW/FW and it is simply a bug that needs to be
> fixed. I withdraw my objections and add my ACK.
> 
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied and queued up for -stable.
