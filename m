From: frank.blaschka@de.ibm.com
Subject: [patch 0/3] s390: network patches for net-next
Date: Mon, 22 Apr 2013 13:12:26 +0200
Message-ID: <20130422111226.882214164@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:43103 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3DVLNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 07:13:13 -0400
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 22 Apr 2013 12:09:29 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Zhang Yanfei (1)
qeth: remove cast for kzalloc return value

Stefan Raspl (2)
qeth: remove unused variable
qeth: Fix missing pointer update

Thanks,
        Frank
