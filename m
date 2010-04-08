From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6 0/3 (TAKE 3)] MLD Snooping on Bridge
Date: Thu, 8 Apr 2010 15:11:39 +0900
Message-ID: <201004080611.o386BdKn015028@94.43.138.210.xn.2iij.net>
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60045 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab0DHGLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 02:11:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

This is 3rd series of patches to support MLD snooping on bridge.

Updates from take 2:
- Don't use silly C99 initizlizer macro.
- Fix pointer manipulation in MLDv2 handler (br_ip6_multicast_mld2_report()).

--yoshfuji

