From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/2] ip_tunnel fixes
Date: Tue, 16 Dec 2014 21:05:19 +0100
Message-ID: <cover.1418759998.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49538 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaLPUFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:05:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf (2):
  ip_tunnel: Add sanity checks to ip_tunnel_encap_add_ops()
  ip_tunnel: Add missing validation of encap type to
    ip_tunnel_encap_setup()

 net/ipv4/ip_tunnel.c | 9 +++++++++
 1 file changed, 9 insertions(+)

-- 
1.9.3
