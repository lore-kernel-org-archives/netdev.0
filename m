From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 0/8][IPIP]: Make IPIP tunnel work in net namespaces.
Date: Tue, 15 Apr 2008 16:25:00 +0400
Message-ID: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43928 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758340AbYDOLul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:50:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make yet another useful virtual device work in namespaces.

This set is also isolated from the other "make xxx device work 
in net namespaces" ones.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
