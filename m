From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 0/4] s390: networking patches for 2.6.33
Date: Fri, 13 Nov 2009 08:46:26 +0100
Message-ID: <20091113074626.078348000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:34865 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbZKMHuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:50:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is a set of networking patches for 2.6.33.

shortlog:
Frank  Blaschka (1)
ctcm: suspend has to wait for outstanding I/O

Ursula Braun (3)
iucv: add work_queue cleanup for suspend
s390: remove cu3088 layer for lcs and ctcm
netiucv: displayed TX bytes value much too high

Thanks,
	Ursula
