From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/16] mib: finish with ipv4 mibs netnsization
Date: Thu, 17 Jul 2008 17:19:09 +0400
Message-ID: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43248 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663AbYGQNTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:19:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the notorious "finalizing set" - after this all the ipv4
stats are isolated from each other. The ipv6, dccp and sctp I
touched with previous sets deserve special handling and will be
done in 2.6.28

No *new* stuff for 2.6.27 from me, thank you Dave for your patience :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
