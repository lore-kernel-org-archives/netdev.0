From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/2] s390/qeth patches for net
Date: Wed, 21 Jan 2015 13:39:08 +0100
Message-ID: <1421843950-58220-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:56269 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbAUMj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:39:27 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 21 Jan 2015 12:39:26 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here are two s390/qeth patches built for net.
One patch is quite large, but we would like to fix the locking warning
seen in recent kernels as soon as possible. But if you want me to submit
these patches for net-next, I will do.

shortlog:

Eugene Crosser (1)
qeth: clean up error handling

Thomas-Mich Richter (1)
qeth: Fix locking warning during qeth device setup

Thanks,
        Ursula
