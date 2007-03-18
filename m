From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] myri10ge updates for 2.6.21
Date: Sun, 18 Mar 2007 21:33:50 +0100
Message-ID: <45FDA22E.1070805@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1929 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932265AbXCRUfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 16:35:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Here's 3 minor updates for myri10ge in 2.6.21:
1. use regular firmware on Serverworks HT2100
2. update wcfifo and intr_coal_delay default values
3. update driver version to 1.3.0-1.225

Please apply.

Thanks,
Brice

