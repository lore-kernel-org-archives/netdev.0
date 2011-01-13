From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: qeth bug fixes for 2.6.38 next rc
Date: Thu, 13 Jan 2011 07:42:23 +0100
Message-ID: <20110113064223.429450048@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:50103 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab1AMGnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 01:43:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are 2 qeth bug fixes for 2.6.38 next rc (net-2.6)

shortlog:

Ursula Braun (1)
qeth: postpone open till recovery is finished

Frank Blaschka (1)
qeth: l3 hw tx csum circumvent hw bug

Thanks,
        Frank
