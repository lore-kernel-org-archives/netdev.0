From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 0/3][TUN]: Make TUN devices work in net namespaces
 (v2).
Date: Tue, 15 Apr 2008 15:49:58 +0400
Message-ID: <48049666.7040204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Maxim Krasnyansky <maxk@qualcomm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52879 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756461AbYDOLQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:16:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change from v1:
* reworked to use generic net pointers.

The first version was Acked-by Maxim.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
