From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: network patches for net-next
Date: Mon, 16 Dec 2013 09:44:50 +0100
Message-ID: <20131216084450.304555472@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:48289 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab3LPIpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:45:21 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 16 Dec 2013 08:45:19 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Ursula Braun (1)
netiucv: improve state checking in conn_action_txdone

Eugene Crosser (1)
qeth: Accurate ethtool output

Thanks,
        Frank
