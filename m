From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: qeth bug fixes for net
Date: Mon, 23 Apr 2012 09:21:40 +0200
Message-ID: <20120423072140.297458261@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:37428 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab2DWHcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 03:32:15 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 23 Apr 2012 08:32:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are two small qeth bug fixes for net.

shortlog:

Ursula Braun (1)
qeth: allow change of blkt default values

Stefan Raspl (1)
qeth: Use blkt defaults for OSA Express 4

Thanks,
        Frank
