From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 2.6.25 8/12][BNX2X]: fixed slowpath races
Date: Tue, 26 Feb 2008 18:07:26 -0800 (PST)
Message-ID: <20080226.180726.168565833.davem@davemloft.net>
References: <1203935586.8232.212.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753422AbYB0CGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 21:06:41 -0500
In-Reply-To: <1203935586.8232.212.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 25 Feb 2008 12:33:06 +0200

> [BNX2X]: fixed slowpath races - fixed up/down racing with timer and fastpath.
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

Applied, but this changelog could have been significantly
improved as per the feedback I gave already on previous
patches in this series.

Really, I highly recommend you look at how some of your
co-workers submit patches to be included, such as Michael
Chan.  He submits perfect changes to us.
