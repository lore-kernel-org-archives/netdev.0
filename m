From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/1] myri10ge update for 2.6.23
Date: Thu, 09 Aug 2007 09:01:30 +0200
Message-ID: <46BABBCA.2060001@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1970 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752896AbXHIHA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 03:00:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Aside from the LRO patch that DaveM queued for 2.6.24, here's a small
fix for myri10ge in 2.6.23:

1. Use the pause counter to avoid a needless device reset

Please apply, thanks,
Brice

