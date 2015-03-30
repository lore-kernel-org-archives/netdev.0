From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/1] af_iucv: fix AF_IUCV sendmsg() errno
Date: Mon, 30 Mar 2015 15:40:41 +0200
Message-ID: <1427722842-49894-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:33128 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbC3NlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 09:41:18 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 14:41:16 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here is a small patch for net fixing a bug in s390 net/iucv/af_iucv.c

shortlog:

Eugene Crosser (1):
  af_iucv: fix AF_IUCV sendmsg() errno

Thanks,
       Ursula
