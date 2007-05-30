From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] myri10ge updates for 2.6.22
Date: Wed, 30 May 2007 21:12:52 +0200
Message-ID: <465DCCB4.5040404@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1991 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752782AbXE3TMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:12:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Here's a small patchset for myri10ge in 2.6.22:
1) report link up/down in standard ethtool way
2) limit the number of recoveries
3) update driver version

Please apply.

Thanks!
Brice

