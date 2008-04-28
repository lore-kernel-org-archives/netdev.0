From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: TCP slowdown in 2.6.25?
Date: Mon, 28 Apr 2008 14:12:13 +0200
Message-ID: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:39160 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763140AbYD1MMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 08:12:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After upgrading from 2.6.23 to 2.6.25 I am seeing a big slow down on
our old www server. Stracing shows lots of EAGAIN but i not sure
these are relevant. I got no idea where to start looking so
I would appreciate some pointers. Perhaps this is a know issue?

CPU is a PowerPC, mpc8321, network driver ucc_geth

 Jocke 
