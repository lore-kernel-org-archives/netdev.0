From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: m_ipt in iproute2
Date: Fri, 9 Jan 2009 02:14:44 +0200
Message-ID: <200901090214.44328.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:46624 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704AbZAIAOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 19:14:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, the bad news, that iptables 1.4.2 won't work again with m_ipt. Again 
something changed, and even ugly way fixes i did for 1.4.1 (for myself, they 
are too ugly for mainline) - doesn't work anymore.

Good news there is xtables.so . Bad news - i have no idea how to use it.
I will try to understand it, but till now m_ipt is broken for 1.4.1 and 1.4.2 
iptables :-(
