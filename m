From: frank.blaschka@de.ibm.com
Subject: [patch 0/3] s390: bug fixes for net
Date: Wed, 25 Jul 2012 10:34:26 +0200
Message-ID: <20120725083426.704834478@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:33257 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932802Ab2GYIfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 04:35:31 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 25 Jul 2012 09:35:29 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some bug fixes for net.

shortlog:

Martin Schwidefsky (1)
net: wiznet add missing HAS_IOMEM dependency

Sebastian Ott (1)
netiucv: cleanup attribute usage

Ursula Braun (1)
qeth: repair crash in qeth_l3_vlan_rx_kill_vid()

Thanks,
        Frank
