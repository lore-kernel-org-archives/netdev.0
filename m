From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Subject: [patch 0/2] spidernet: support for bcm5461 and new setting
Date: Thu, 4 May 2006 11:59:22 +0200
Message-ID: <200605041159.22584.Jens.Osterkamp@de.ibm.com>
Reply-To: Jens.Osterkamp@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd.bergmann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:18713 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751154AbWEDJ7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 05:59:25 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k449xNgB176916
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 09:59:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k44A0aYd091934
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 12:00:36 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k449xMBr017700
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 11:59:23 +0200
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The first patch introduces a new PHY BCM5461 as the BCM5421 will be no
longer produced. Besides that it generalizes the way, PHYs are
switched into fiber mode.
The second introduces a new setting that we need to make the driver
work more reliable.

Please apply.

Jens
