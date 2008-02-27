From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 2.6.25 2/12][BNX2X]: fix bnx2x_init_one()
Date: Tue, 26 Feb 2008 18:00:29 -0800 (PST)
Message-ID: <20080226.180029.182411272.davem@davemloft.net>
References: <1203935568.8232.206.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52194
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759933AbYB0B7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 20:59:44 -0500
In-Reply-To: <1203935568.8232.206.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 25 Feb 2008 12:32:48 +0200

> [BNX2X]: fix bnx2x_init_one() - was printing wrong PCI-E info, failed to release netdev in one case.
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

Applied.

Please, in the future, make the header line of your
changelog entry brief.  Say, 80 characters long or
shorter.

Put the meat of the description into the following
lines.
