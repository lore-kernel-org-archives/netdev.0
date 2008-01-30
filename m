From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7][BNX2]: Update firmware.
Date: Tue, 29 Jan 2008 21:16:03 -0800 (PST)
Message-ID: <20080129.211603.50722237.davem@davemloft.net>
References: <1201652420.19087.15.camel@dell>
	<20080129234615.GB25253@stro.at>
	<1201660196.19087.29.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: max@stro.at, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36892
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751391AbYA3FPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 00:15:45 -0500
In-Reply-To: <1201660196.19087.29.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 29 Jan 2008 18:29:56 -0800

> Didn't we beat this topic to death last time?

Yes we did.

> Once again, the driver is tightly coupled with the firmware.  We don't
> want things to break when users upgrade or downgrade the kernel.  Coding
> the driver to deal with different firmware versions will add a lot of
> complexity.

I absolutely agree with Michael here.
