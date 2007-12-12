From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8][BNX2]: Add fast path code to handle RX pages.
Date: Wed, 12 Dec 2007 11:19:43 -0800 (PST)
Message-ID: <20071212.111943.183145706.davem@davemloft.net>
References: <1197486000.16386.31.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751973AbXLLTTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:19:44 -0500
In-Reply-To: <1197486000.16386.31.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 12 Dec 2007 11:00:00 -0800

> [BNX2]: Add fast path code to handle RX pages.
> 
> Add function to reuse a page in case of allocation or other errors.
> Add code to construct the completed SKB with the additional data in
> the pages.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
