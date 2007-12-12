From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8][BNX2]: Restructure RX fast path handling.
Date: Wed, 12 Dec 2007 11:17:14 -0800 (PST)
Message-ID: <20071212.111714.69138276.davem@davemloft.net>
References: <1197485923.16386.27.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753555AbXLLTRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:17:15 -0500
In-Reply-To: <1197485923.16386.27.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 12 Dec 2007 10:58:43 -0800

> [BNX2]: Restructure RX fast path handling.
> 
> Add a new function to handle new SKB allocation and to prepare the
> completed SKB.  This makes it easier to add support for non-linear
> SKB.
>  
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
