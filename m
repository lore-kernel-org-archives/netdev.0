From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.28] myri10ge updates + multiqueue TX
Date: Fri, 12 Sep 2008 19:46:23 +0200
Message-ID: <48CAAAEF.1060205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1921 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753399AbYILRs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 13:48:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

Here's a first batch of patches for myri10ge in 2.6.28:
1) Stop scaring people when DCA is built but absent
2) Rename dca-related firmware counters
3) Add Toeplitz-hashing related routines
4) Add multiqueue TX support

thanks,
Brice

