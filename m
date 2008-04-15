From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 0/8][SIT]: Make SIT tunnel work in net namespaces.
Date: Tue, 15 Apr 2008 17:26:18 +0400
Message-ID: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44435 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbYDOMv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:51:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4 tunnels are done - time to virtualize ipv6 tunnels.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
