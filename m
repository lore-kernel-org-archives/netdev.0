From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: network bug fixes for net
Date: Tue, 16 Oct 2012 07:21:16 +0200
Message-ID: <20121016052116.210859505@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:49057 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab2JPFXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 01:23:37 -0400
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 16 Oct 2012 06:23:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some bug fixes for net.

shortlog:

Hendrik Brueckner (1)
smsgiucv: reestablish IUCV path after resume

Stefan Raspl (1)
qeth: fix deadlock between recovery and bonding driver

Thanks,
        Frank
