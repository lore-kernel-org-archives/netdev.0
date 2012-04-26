From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 0/2] drop_monitor: misc fixes for some recently reported bugs
Date: Thu, 26 Apr 2012 14:47:00 -0400
Message-ID: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57991 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505Ab2DZSrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 14:47:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	Eric was using dropwatch recently and reported a few bugs to me that he
had noted.  This short series should fix them all up.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>                                                                                                                                                                                       
CC: Eric Dumazet <eric.dumazet@gmail.com>                                                                                                                                                                                       
CC: David Miller <davem@davemloft.net>
