From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH0/2] [POWERPC] Two bug fixes for 2.6.24
Date: Sat, 03 Nov 2007 20:00:57 +0100
Message-ID: <472CC569.9050502@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>,
	Scott Wood <scottwood@freescale.com>,
	Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>
To: "linuxppc-embedded@ozlabs.org" <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail0.scram.de ([78.47.204.202]:42088 "EHLO mail0.scram.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755174AbXKCTBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 15:01:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a series fixing some bugs for 8xx powerpc CPUs.

1. [POWERPC] Kill non-existant symbols from ksyms and commproc.h
2. [POWERPC] fs_enet: select PHYLIB as the driver needs it

This series can be pulled from git://git.bocc.de/dbox2.git for-2.6.24

Thanks,
Jochen


