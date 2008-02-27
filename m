From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 2.6.25 3/12][BNX2X]: Link mgmt and BC bugs
Date: Tue, 26 Feb 2008 18:02:12 -0800 (PST)
Message-ID: <20080226.180212.147022381.davem@davemloft.net>
References: <1203935570.8232.207.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52199
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751505AbYB0CB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 21:01:27 -0500
In-Reply-To: <1203935570.8232.207.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 25 Feb 2008 12:32:50 +0200

> [BNX2X]: Link mgmt and BC bugs - many link cfg fixes
> 
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

I'm not applying this, this changelog entry tells me,
and anyone else who reads it, nothing at all about
what exactly is fixed and in what way by these changes.

I also want you guys to remove that bogus CVS revision string.  It
serves no purpose for it to appear in the upstream kernel sources.

If you need to you can corrolate the in-tree driver version with
whatever CVS magic you guys do internally.

I'm sorry I didn't notice this when including the driver initially, I
would have had it removed back then had I noticed.

Thanks.
