From: frank.blaschka@de.ibm.com
Subject: [patch 0/7] s390: network patches for net-next
Date: Mon, 28 Apr 2014 10:05:04 +0200
Message-ID: <20140428080504.925649066@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:48248 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaD1IFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 04:05:38 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 28 Apr 2014 09:05:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Stefan Raspl (3)
qeth: Fix default queue setting in priority queueing
qeth: Extend priority queueing to IPv6
qeth: Add new priority queueing options

Duan Jiong (2)
lcs: replace PTR_RET with PTR_ERR_OR_ZERO
qeth: replace PTR_RET with PTR_ERR_OR_ZERO

Frank Blaschka (2)
claw: replace PTR_RET with PTR_ERR_OR_ZERO
ctc: replace PTR_RET with PTR_ERR_OR_ZERO

Thanks,
        Frank
