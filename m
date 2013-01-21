From: frank.blaschka@de.ibm.com
Subject: [patch 0/6] s390: network patches for net-next
Date: Mon, 21 Jan 2013 13:30:17 +0100
Message-ID: <20130121123017.240686588@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:40847 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476Ab3AUMal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:30:41 -0500
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jan 2013 12:29:21 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Stefan Raspl (6)
qeth: Fix retry logic in hardsetup
qeth: Remove unused exports
qeth: Support VEPA mode
qeth: Update Kconfig wording
qeth: Make s390dbf card entries persistent
qeth: Fix HiperSockets performance regression

Thanks,
        Frank
