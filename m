From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/20] mib: add struct net to IP, TCP and NET macros
Date: Wed, 16 Jul 2008 12:05:10 +0400
Message-ID: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51295 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754409AbYGPIFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:05:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is actually the last very scattered set, that changes many calls
to MIB accounting macros. What is left requires less patching.

David, I hope this (and a finalizing set, I will prepare after this
one is accepted) can go to current 2.6.27 merge window, but it is OK
with me if your decision is to delay this till 2.6.28.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
