From: "voncken" <cedric.voncken@acksys.fr>
Subject: Gianfar : Q : Tx VLAN hardware accelaration
Date: Fri, 1 Feb 2013 10:45:42 +0100
Message-ID: <001401ce0060$e686afd0$b3940f70$@acksys.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Claudiu Manoil'" <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.msg.oleane.net ([62.161.4.2]:38686 "EHLO
	smtp02.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab3BAJpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 04:45:45 -0500
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi Claudiu,

I would like to send on the same Ethernet interface (so the same eTSEC) a
frame with VLAN tag and without VLAN tag.

If I understand correctly mpc8315 Family reference manual rev 2, when TX
VLAN hardware acceleration is enable, the eTSEC always add the VLAN TAG
-from FCB or from the default TAG register).

Could you confirm is not possible to send frame without tag when Tx VLAN
hardware acceleration is enable?

Thanks
