From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] myri10ge update
Date: Mon, 14 Aug 2006 17:52:33 -0400
Message-ID: <44E0F0A1.2000104@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:37862 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751378AbWHNVxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:53:12 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here's 3 new minor updates for the myri10ge driver:

1) define some previously hardwired firmware constants
2) allow to disable link status change reporting
3) convert to netdev_alloc_skb

Please apply.

Thank you
Brice Goglin

