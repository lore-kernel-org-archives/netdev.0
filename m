From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 12:39:14 -0800 (PST)
Message-ID: <20100105.123914.215084522.davem@davemloft.net>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	<20100105090717.15d532ce@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	dhananjay.phadke@qlogic.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932148Ab0AEUjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 15:39:10 -0500
In-Reply-To: <20100105090717.15d532ce@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 5 Jan 2010 09:07:17 -0800

> I assume Dave will just resolve this by combining the two before
> merging.

Don't assume anything. :-)

Patches should be submitted such that they compile when applied
in-order and are fully bisectable.
