From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 00/10][RFC] mv643xx_eth: updates for 2.6.27
Date: Wed, 16 Jul 2008 12:31:22 +0200
Message-ID: <20080716103122.GA8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44713 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759571AbYGPKbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:31:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this series the NETPOLL build fix that was posted earlier, a
couple of important fixes for potential transmit hangs, and a
number of other minor fixes and changes.
