From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: network patches for net-next
Date: Wed, 19 Mar 2014 07:57:58 +0100
Message-ID: <20140319065758.841490297@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:41136 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757595AbaCSG6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 02:58:17 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 19 Mar 2014 06:58:16 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Ursula Braun (1)
af_iucv: recvmsg problem for SOCK_STREAM sockets

Heiko Carstens (1)
qeth: make qeth_query_card_info_cb() static

Stefan Raspl (2)
qeth: Removed unused parameter
qeth: Fix IP version detection for VLAN traffic

Thanks,
        Frank
