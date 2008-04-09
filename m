From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] BNX2X: Correct bringing chip out of reset
Date: Wed, 09 Apr 2008 15:26:29 -0700 (PDT)
Message-ID: <20080409.152629.24175116.davem@davemloft.net>
References: <1207475082.13326.17.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54727
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753918AbYDIW03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 18:26:29 -0400
In-Reply-To: <1207475082.13326.17.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Sun, 06 Apr 2008 12:44:42 +0300

> BNX2X: Correct bringing chip out of reset
> 
> Fixed bug: Wrong register was written to when bringing the chip out of reset.
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

Applied, Mr. Impatient.

I had to bump the driver version and release date, please
always do this in your patches especially when making
bug fixes of this magnitude.
