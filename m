From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 0/8][GRE]: Make IPGRE tunnel work in net namespaces.
Date: Tue, 15 Apr 2008 16:45:40 +0400
Message-ID: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52649 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbYDOMLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:11:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is mostly the same as the ipip one.

Hm... these sets are more likely ~8 patches each, not
~7 as I promised earlier...

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
