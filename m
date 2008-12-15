From: David Miller <davem@davemloft.net>
Subject: Re: niu: ethtool -s support -> implementation by contractor
Date: Mon, 15 Dec 2008 12:11:05 -0800 (PST)
Message-ID: <20081215.121105.114523167.davem@davemloft.net>
References: <20081125.133124.74121407.davem@davemloft.net>
	<20081126095021.GB20045@schweikert.ch>
	<20081215161215.GD26374@schweikert.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david@schweikert.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752842AbYLOULE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 15:11:04 -0500
In-Reply-To: <20081215161215.GD26374@schweikert.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Schweikert <david@schweikert.ch>
Date: Mon, 15 Dec 2008 17:12:15 +0100

> Should anything in particular be done in order for the future patch
> to have good chances of being integrated in the main branch?

Follow "linux/Documentation/SubmittingPatches" and adhere to
the existing coding style in the driver and you should be
fine.

