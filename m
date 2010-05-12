From: frank.blaschka@de.ibm.com
Subject: [patch 0/3] s390: qeth patches for 2.6.35
Date: Wed, 12 May 2010 07:34:44 +0200
Message-ID: <20100512053444.035939000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:37405 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab0ELFfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 01:35:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some qeth patches for 2.6.35 (net-next).

shortlog:
Ursula Braun (1)
qeth: new message if OLM limit is reached

Frank Blaschka (2)
qeth: exploit HW TX checksumming
qeth: synchronize configuration interface

Thanks,
        Frank
