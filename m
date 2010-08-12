From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 0/2] s390: claw and ctcm patches
Date: Thu, 12 Aug 2010 13:58:26 +0200
Message-ID: <20100812115826.983015000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:41446 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758822Ab0HLMGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 08:06:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

these patches repair warnings seen with the linux-2.6.git 2.6.35
caused by the used constants READ / WRITE.

The patches apply on linux-2.6.git and net-next-2.6.git.

shortlog:
Heiko Carstens (1)
claw: rename READ/WRITE defines to avoid redefinitions

Ursula Braun (1)
ctcm: rename READ/WRITE defines to avoid redefinitions

Thanks,
      Ursula

