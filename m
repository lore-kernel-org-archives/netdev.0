From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/4] s390: ctc patches for 2.6.25 (3rd try)
Date: Wed, 06 Feb 2008 19:27:23 +0100
Message-ID: <20080206182723.103842000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:10555 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbYBFSaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 13:30:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Jeff,

hmmm, another send is necessary, sorry again.
Description for patch 3/4 needs to be changed.

The following patches are intended for 2.6.25. Besides clean-ups
they replace the old ctc driver by a reworked ctcm driver.
This ctcm driver supports the channel-to-channel connections of the
old ctc driver plus an additional MPC protocol to provide SNA
connectivity.

Patch 1/4: clean-ups in ctc and netiucv
Patch 2/4: clean-ups in Kconfig
Patch 3/4: reworked ctc driver
Patch 4/4: removal of old ctc driver

Regards,    Ursula Braun

