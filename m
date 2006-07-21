From: Brice Goglin <brice@myri.com>
Subject: [patch 0/2] myri10ge minor fixes
Date: Fri, 21 Jul 2006 15:48:46 -0400
Message-ID: <44C12F9E.9080206@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:57800 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751127AbWGUTtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 15:49:25 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following patches fix 2 minor issues in the myri10ge driver:
1) Always do a dummy RDMA after loading the firmware
2) Write the firmware in 256-bytes chunks

Please apply.
thanks,
Brice

