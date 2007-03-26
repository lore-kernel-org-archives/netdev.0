From: Chuck Ebbert <cebbert@redhat.com>
Subject: Interrupt posted but not delivered
Date: Sun, 25 Mar 2007 20:28:05 -0400
Message-ID: <46071395.20203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933211AbXCZA2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 20:28:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've now seen several reports of this message from the 3Com
3c59x driver.  This seems to be a very old problem that has
somehow come back starting with kernel 2.6.19 AFAICT. What
could cause this?

