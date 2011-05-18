From: frank.blaschka@de.ibm.com
Subject: [patch 0/1] s390: one more qeth patch for net-next
Date: Wed, 18 May 2011 15:28:34 +0200
Message-ID: <20110518132834.728225299@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:33453 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757193Ab1ERN3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 09:29:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

thanks to the help and patience of Michal Miroslaw here is a
patch to finalize the qeth hw_features rework.

shortlog:
Frank Blaschka (1)
qeth: use ndo_set_features callback for initial setup and recovery

Thanks,
        Frank

