From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/1] myri10ge update for 2.6.23
Date: Fri, 13 Jul 2007 20:14:00 +0200
Message-ID: <4697C0E8.40003@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1938 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751797AbXGMSMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 14:12:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Almost nothing new regarding myri10ge in 2.6.23 for now, just a single
patch to remove some non-sensical code in the tx done routine.

Please apply, thanks,
Brice

