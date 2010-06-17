From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 0/5]qlcnic: fixes
Date: Thu, 17 Jun 2010 05:56:37 -0700
Message-ID: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5180 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751748Ab0FQM4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 08:56:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi
   Sending series of 5 patches, mainly to improve rx performance and
   fix netif_stop_queue race.

   Please apply them on net-next.

-Amit
