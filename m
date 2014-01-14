From: frank.blaschka@de.ibm.com
Subject: [patch 0/3] s390: network patches for net-next
Date: Tue, 14 Jan 2014 15:54:10 +0100
Message-ID: <20140114145410.453840919@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:37978 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaANOzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 09:55:13 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 14 Jan 2014 14:55:11 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Eugene Crosser (3)
qeth: bridgeport support - basic control

390/qdio: bridgeport support - CHSC part
  Since this patch touches CIO and qdio it will come in again with
  the s390 tree from Martin Schwidefsky.

qeth: bridgeport support - address notifications

Thanks,
        Frank
