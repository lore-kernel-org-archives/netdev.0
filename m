From: frank.blaschka@de.ibm.com
Subject: [patch 0/6] s390: network patches for net-next
Date: Mon, 19 Nov 2012 13:46:44 +0100
Message-ID: <20121119124644.679089322@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:57023 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab2KSMrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 07:47:05 -0500
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 19 Nov 2012 12:47:03 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Stefan Raspl (4)
qeth: Remove unused variable
qeth: Consolidate tracing of card features
qeth: Clarify card type naming for virtual NICs
qeth: Remove BUG_ONs

Ursula Braun (2)
ctcm: remove BUG_ON's
claw: remove BUG_ON's


Thanks,
        Frank
