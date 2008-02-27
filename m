From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 2.6.25 9/12][BNX2X]: workaround PCI queue
 overflow
Date: Tue, 26 Feb 2008 18:07:53 -0800 (PST)
Message-ID: <20080226.180753.10679149.davem@davemloft.net>
References: <1203935588.8232.213.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753898AbYB0CHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 21:07:08 -0500
In-Reply-To: <1203935588.8232.213.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 25 Feb 2008 12:33:08 +0200

> [BNX2X]: workaround PCI queue overflow - limit traffic through an internal queue to prevent overflow. 
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

Applied.
