From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: network patches for net-next V1
Date: Wed, 28 May 2014 10:22:27 +0200
Message-ID: <20140528082227.024995099@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:53415 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaE1IWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 04:22:45 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 28 May 2014 09:22:43 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next
Added some style fixing reported by David Laight.

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
