From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 0/2] net: support for TX timestamps
Date: Tue, 29 Jul 2008 03:35:51 +0300
Message-ID: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:25529 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751561AbYG2AiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 20:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

This patches adds TX timestamping support and is main use case is the
Precision Time Protocol (IEEE 1588). Both software and hardware
timestamping can be used.

Thanks,
tavi


