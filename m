From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: network patches for net-next
Date: Mon, 21 Jul 2014 12:54:42 +0200
Message-ID: <20140721105442.533889716@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:43553 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754350AbaGUKzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 06:55:09 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jul 2014 11:55:07 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Stefan Raspl (1)
qeth: Display adjacent switch attributes

Ursula Braun (1)
af_iucv: avoid path quiesce of severed path in shutdown()

Thanks,
        Frank
