From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: Fixed PHY regression
Date: Mon, 8 Oct 2007 20:17:33 +0200
Message-ID: <008601c809d7$7f5dc710$04ac10ac@Jocke>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:28490 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752328AbXJHSWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:22:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David, any chance the second item, Oops while modprobing phy fixed module, in
http://marc.info/?l=linux-kernel&m=119178673421891&w=2
will make it into 2.6.23? 

The fix is now in your tree,
http://git.kernel.org/?p=linux/kernel/git/davem/bak-net-2.6.24.git;a=commit;h=bbb4c0c35a4c2aed5e025b668c8dfc99c5b74cff

It has been in Andrews tree for a while, then in Garzik and now it is in your tree.

 Regards Jocke

