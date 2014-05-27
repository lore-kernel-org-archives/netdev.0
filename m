From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: network patches for net-next
Date: Tue, 27 May 2014 11:13:41 +0200
Message-ID: <20140527091341.417448231@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:55158 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbaE0JOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 05:14:07 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 27 May 2014 10:14:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Philipp Hachtmann (1)
af_iucv: Add automatic (source) iucv_name to bind

Ursula Braun (2)
af_iucv: correct cleanup if listen backlog is full
s390/net: fix format string mismatches

Rickard Strandqvist (1)
qeth: Fix for possible null pointer dereference

Thanks,
        Frank
