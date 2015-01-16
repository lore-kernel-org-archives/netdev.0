From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/5] s390: network patches for net-next
Date: Fri, 16 Jan 2015 14:05:44 +0100
Message-ID: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:33018 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbbAPNFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:05:55 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 16 Jan 2015 13:05:54 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Aya Mahfouz (1)
ctcm,netiucv: migrate variables to handle y2038 problem

Markus Elfring (1)
s390/net: Delete useless checks before function calls

Eugene Crosser (2)
qeth: use qeth_card_hw_is_reachable() everywhere
qeth: sysfs: replace strcmp() with sysfs_streq()

Thomas-Mich Richter (1)
qeth: Remove unneeded structure member

Thanks,
        Ursula
