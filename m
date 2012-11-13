From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: network bug fixes for net
Date: Tue, 13 Nov 2012 10:05:15 +0100
Message-ID: <20121113090515.223638702@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:36629 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208Ab2KMJFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:05:35 -0500
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 13 Nov 2012 09:05:33 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are 2 bug fixes for net.

shortlog:

Ursula Braun (1)
qeth: set new mac even if old mac is gone

Stefan Raspl (1)
qeth: Fix IPA_CMD_QIPASSIST return code handling

Thanks,
        Frank
