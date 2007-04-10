From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] last myri10ge updates for 2.6.21
Date: Tue, 10 Apr 2007 21:20:18 +0200
Message-ID: <461BE372.2000600@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1976 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753156AbXDJTVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 15:21:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

In case it is not too late for 2.6.21, here are 3 minor fixes for myri10ge:
1. fix management of the firmware 4KB boundary crossing restriction
2. more Intel chipsets providing aligned PCIe completions
3. update driver version to 1.3.0-1.233

Thanks,
Brice

