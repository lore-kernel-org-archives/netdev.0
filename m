From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/2] myri10ge update for 2.6.27
Date: Mon, 21 Jul 2008 10:25:11 +0200
Message-ID: <488447E7.2060505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1849 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754439AbYGUIZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 04:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

Here are 2 small myri10ge patches for 2.6.27:
1) remove the obsolete wcfifo code
2) use ioremap_wc()

A multiqueue TX patch is underwork but I am not sure it will be ready
for 2.6.27. We'll see.

thanks,
Brice

