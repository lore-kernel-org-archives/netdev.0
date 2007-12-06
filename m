From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: ucc_geth 10 Mbit/s locks up CPU even though NAPI is enabled
Date: Thu, 06 Dec 2007 18:22:19 +0100
Message-ID: <1196961739.937.17.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: 'linuxppc-dev Development' <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:10914 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750705AbXLFRWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 12:22:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Injecting a 10 MBit/s stream with 64 bytes pkgs locks up my
MPC832x CPU even though I got NAPI enabled. Kernel 2.6.23

Any ideas?

 Jocke
