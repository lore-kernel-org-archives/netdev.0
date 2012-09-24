From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] s390: network patches for net-next
Date: Mon, 24 Sep 2012 16:24:22 +0200
Message-ID: <20120924142422.001953152@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:48511 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755671Ab2IXOZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:25:09 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Sep 2012 15:25:08 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next

shortlog:

Sebastian Ott(2)
qeth: cleanup channel path descriptor function
lcs: ensure proper ccw setup

Wei Yongjun(1)
qeth: fix possible memory leak in qeth_l3_add_[vipa|rxip]()

Peter Senna(2)
drivers/s390/net: removes unnecessary semicolon
ctcm: fix error return code

Thanks,
        Frank
