From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/3] s390: qeth patches for net-next
Date: Wed, 19 Aug 2015 10:20:51 +0200
Message-ID: <1439972454-64347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:40609 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbbHSIVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 04:21:13 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 19 Aug 2015 09:21:11 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here are some s390 related qeth patches for net-next

shortlog:

Eugene Crosser (1):
  qeth: remove extraneous length from %pM format

Vaishali Thakkar (1):
  qeth: Convert use of __constant_htons to htons

Lakhvich Dmitriy (1):
  qeth: no write permission for readonly sysattr

Thanks,
       Ursula
