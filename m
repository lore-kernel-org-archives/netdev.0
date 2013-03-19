From: frank.blaschka@de.ibm.com
Subject: [patch 0/3] s390: network bug fixes for net
Date: Tue, 19 Mar 2013 07:04:41 +0100
Message-ID: <20130319060441.956271217@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:57339 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933915Ab3CSGFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 02:05:00 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 19 Mar 2013 06:02:37 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are 3 bug fixes for net.

shortlog:

Stefan Raspl (2)
qeth: delay feature trace
qeth: Fix invalid router settings handling

Frank Blaschka (1)
qeth: Fix scatter-gather regression

Thanks,
        Frank
