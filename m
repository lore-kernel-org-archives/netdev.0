From: frank.blaschka@de.ibm.com
Subject: [patch 0/6] s390: network driver features and fixes for net-next
Date: Wed, 08 Feb 2012 11:19:44 +0100
Message-ID: <20120208101944.272235343@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:33779 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756313Ab2BHKUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 05:20:37 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 8 Feb 2012 10:20:32 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 network driver features and fixes for net-next

shortlog:

Ursula Braun (5)
af_iucv: remove IUCV-pathes completely
af_iucv: block writing if msg limit is exceeded
af_iucv: change net_device handling for HS transport
af_iucv: allow retrieval of maximum message size
qeth: add wake_up on write channel

Frank Blaschka (1)
qeth: add query OSA address table support

Thanks,
        Frank
