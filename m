From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: request for backporting commit 99d3016de4 to 3.14 (stable)
Date: Tue, 27 May 2014 15:32:08 +0000
Message-ID: <7788d6445c894835bf2e1dc64a77e797@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bernhard Walle <bernhard@bwalle.de>,
	KY Srinivasan <kys@microsoft.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-sn2-obe.ptr.o365filtering.com ([157.55.158.27]:58713 "EHLO
	na01-sn2-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752885AbaE0PcT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 11:32:19 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

I found this commit is in stable tree already. Will it be backported into 3.14 as well? Otherwise, can we request it to be included into the next 3.14 update?

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/drivers/net/hyperv?id=99d3016de4f2a29635f5382b0e9bd0e5f2151487
	hyperv: Change the receive buffer size for legacy hosts

Thanks,
- Haiyang
