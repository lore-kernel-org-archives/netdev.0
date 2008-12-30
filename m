From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Subject: [PATCH -net-next 0/4] firmware patches for net drivers
Date: Tue, 30 Dec 2008 13:53:34 +0530
Message-ID: <1230625414.24796.8.camel__16577.3995373913$1230626422$gmane$org@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, davem@redhat.com,
	Jeff Garzik <jeff@garzik.org>, jgarzik@redhat.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.k
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45987 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbYL3Iiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 03:38:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are floating in linux-next trees from long time but now we are
sending these patches directly to the appropriate maintainers/mailing lists
so that they apply through proper channel.

1. firmware: convert e100 driver to request_firmware()
2. firmware: convert acenic driver to request_firmware()
3. firmware: convert tg3 driver to request_firmware()
4. starfire: use request_firmware()

Thank you,
	JSR

