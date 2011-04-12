From: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Subject: SMSC 8720a/MDIO/PHY help.
Date: Tue, 12 Apr 2011 16:46:09 -0500
Message-ID: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c11o148.mxlogic.net ([208.65.144.81]:54056 "EHLO
	p02c11o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303Ab1DLVyb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:54:31 -0400
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have written my MDIO driver, registered it via mdiobus_register(), and
have verified that the SCMS LAN8710 driver picks it up (via sysfs).
What am I missing?  The state machine never starts.  I get no runs,
hits, or errors (and nobody left -- it is baseball season after all).

If you have an idea of something for me to try, I'd love to entertain
it.

Thanks,
Andy
