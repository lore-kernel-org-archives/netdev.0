From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 19:53:26 -0800 (PST)
Message-ID: <20100105.195326.51503723.davem@davemloft.net>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	<20100105090717.15d532ce@nehalam>
	<99737F4847ED0A48AECC9F4A1974A4B80CFE94343B@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754756Ab0AFDxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 22:53:21 -0500
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80CFE94343B@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Salecha <amit.salecha@qlogic.com>
Date: Tue, 5 Jan 2010 20:24:18 -0600

> I bisected patches logically, for ease of understanding.
> If single patch is requirement, I can do that also.

You didn't bisect anything, we're talking about GIT bisection.

At each step of the way, the tree must build if all available
kernel config options are enabled.
