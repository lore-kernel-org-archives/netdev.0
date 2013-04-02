From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: network bug fixes for net
Date: Tue, 02 Apr 2013 12:56:50 +0200
Message-ID: <20130402105650.056630101@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:35788 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932330Ab3DBK5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 06:57:14 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 2 Apr 2013 11:54:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are 2 bug fixes for net.

shortlog:

Hendrik Brueckner (1)
af_iucv: recvmsg: use correct skb_pull() function

Stefan Raspl (1)
qeth: fix qeth_wait_for_threads() deadlock for OSN devices

Thanks,
        Frank
