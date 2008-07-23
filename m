From: Arjan van de Ven <arjan@infradead.org>
Subject: bunch of warnings in __netif_schedule
Date: Wed, 23 Jul 2008 12:09:38 -0700
Message-ID: <20080723120938.36c42453@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51332 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbYGXBp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 21:45:58 -0400
Received: from c-71-193-193-226.hsd1.or.comcast.net ([71.193.193.226] helo=localhost.localdomain)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1KLptS-0006xb-3i
	for netdev@vger.kernel.org; Thu, 24 Jul 2008 01:45:22 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

kerneloops.org also picked up a series of warnings in __netif_schedule:
 http://www.kerneloops.org/search.php?search=__netif_schedule

afaics Dave is on top of most of them; just wanted to mention it here
in case some got missed...


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
