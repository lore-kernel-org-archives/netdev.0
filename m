From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/34]bnx2x: Indirection table initialization index
Date: Wed, 14 Jan 2009 21:30:06 -0800 (PST)
Message-ID: <20090114.213006.110006234.davem@davemloft.net>
References: <1231951407.11301.136.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752261AbZAOFaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:30:05 -0500
In-Reply-To: <1231951407.11301.136.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:27 +0200

> Wrong initialization of the multi-queue indirection table - it
> should be using the function and not the port index
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
