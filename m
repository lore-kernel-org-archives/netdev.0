From: Raz <raziebe@gmail.com>
Subject: 10G intel cards - streaming for over than 30 minutes
Date: Tue, 9 Dec 2008 00:41:03 +0200
Message-ID: <5d96567b0812081441i4014fb6cvba782e51d9a30eb5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:59489 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbYLHWlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 17:41:04 -0500
Received: by yx-out-2324.google.com with SMTP id 8so568737yxm.1
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 14:41:03 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, one of my interfaces decided to go to sleep.

ixgbe: eth4: ixgbe_watchdog_task: NIC Link is Up 10 Gbps, Flow Control: None
NETDEV WATCHDOG: eth4: transmit timed out

Does anyone know whether this is a bug that was fixed ( my kernel
2.6.18-8.el5 ).

thank you
