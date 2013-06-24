From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] s390: network patches for net-next
Date: Mon, 24 Jun 2013 13:21:47 +0200
Message-ID: <20130624112147.347247916@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:33168 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621Ab3FXLWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 07:22:31 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Jun 2013 12:17:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Andy Shevchenko (1)
netiucv: remove unused macro

Stefan Raspl (2)
qeth: Increase default MTU for OSA devices
qeth: Fix crash on initial MTU size change

Ursula Braun (1)
qeth: change default standard blkt settings for OSA

Sebastian Ott (1)
qeth: use default napi weight

Thanks,
        Frank
