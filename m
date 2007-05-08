From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 0/3] Intel IXP4xx network drivers
Date: Tue, 08 May 2007 03:40:56 +0200
Message-ID: <m3vef43xef.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55527 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934429AbXEHBk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 21:40:57 -0400
In-Reply-To: <m3abwhcy74.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Mon, 07 May 2007 01:46:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, the status of my patches is as follows:
[PATCH] Use menuconfig objects II - netdev/wan
        the "menuconfig" WAN patch by Jan Engelhardt

[PATCH 1a/3] WAN Kconfig: change "depends on HDLC" to "select"
        the Kconfig changes for WAN (HDLC) drivers

[PATCH 2a/3] Intel IXP4xx network drivers
	IXP4xx "fuses" (installed on-chip CPU components) patch

[PATCH] Intel IXP4xx network drivers v.3 - QMGR
	IXP4xx hardware Queue Manager driver

[PATCH] Intel IXP4xx network drivers v.2 - NPE
	IXP4xx Network Processor Engine driver, needs "fuses" patch

[PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
	You guessed it, needs all of the above.


The:
[PATCH] Intel IXP4xx network drivers v.2 - QMGR
was faulty, thus v.3.

Fire again :-)
-- 
Krzysztof Halasa
