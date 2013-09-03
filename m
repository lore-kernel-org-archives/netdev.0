From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: VLAN HW accel, performance advantage?
Date: Tue, 3 Sep 2013 11:05:43 +0200
Message-ID: <OF00E35E7C.7482EC01-ONC1257BDB.00314AD0-C1257BDB.0031F6D0@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:65298 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905Ab3ICJOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 05:14:45 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 9F94B258021
	for <netdev@vger.kernel.org>; Tue,  3 Sep 2013 11:05:44 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am considering impl. VLAN HW acceleration in Freescales ucc_geth driver 
to improve
performance, primarily for bridged interfaces.
 I am hoping the community has some insights as to what performance gains 
one
could expect?

   Jocke
