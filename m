From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/2] myri10ge small updates for 2.6.27
Date: Wed, 06 Aug 2008 16:13:44 +0200
Message-ID: <4899B198.1060508@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2013 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754616AbYHFOPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 10:15:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

Here are 2 small updates for myri10ge in 2.6.27.
1) myri10ge: update firmware headers
2) myri10ge: set 64bits consistent DMA mask

We are working on multiqueue TX support but I don't know when
the patch will be ready, so I am sending everything else now.

thanks,
Brice


