From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v3 00/12] DM9000 for next kernel release.
Date: Tue, 24 Jun 2008 22:15:56 +0100
Message-ID: <20080624211556.566149406@fluff.org.uk>
Cc: jeff@garzik.org, laurentp@cse-semaphore.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:64012 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754025AbYFXVTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 17:19:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a new DM9000 series, with some minor
fixups and a couple of changes:

1) Fixes for checkpatch.pl have been appied

2) Update the output when using NSR link polling
   to look more like the MII outputs, and some
   tidying of the resultant code.

3) Add some documentation for the driver.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
