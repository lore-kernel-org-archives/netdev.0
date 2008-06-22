From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v2 00/11] DM9000 patch series for next kernel
Date: Sun, 22 Jun 2008 21:16:45 +0100
Message-ID: <20080622201645.041001353@fluff.org.uk>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:56694 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753886AbYFVUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:19:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of patches for the next kernel release
mainly from myself (including two from Laurent) to update
DM9000 functionality.

I have dropped the total remove of the blackfin #ifdef as
there is some thought needed and I would prefer to ensure
this series gets merged and sort out the blackfin changes
without the time pressure of an imminent kernel release.

This series is based on -rc7 with the next20080620 tree
applied to it, so should be up to date with current work.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
