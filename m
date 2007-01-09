From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] myri10ge minor updates for 2.6.20
Date: Tue, 09 Jan 2007 21:03:11 +0100
Message-ID: <45A3F4FF.5000803@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-64-172-73-26.dsl.lsan03.pacbell.net ([64.172.73.26]:1798
	"EHLO myri.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932393AbXAIUa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 15:30:26 -0500
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

These should be the last 3 patches to finalize myri10ge version 1.2.0:
1. myri10ge: make wc_fifo usage load-time tunable
2. myri10ge: check that we can get an irq
3. myri10ge: update driver version to 1.2.0

Please apply to 2.6.20.
thanks,
Brice

