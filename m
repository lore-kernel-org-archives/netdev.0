From: maximilian attems <max@stro.at>
Subject: sis190 build breakage
Date: Tue, 29 Jan 2008 22:50:23 +0100
Message-ID: <20080129215023.GA24152@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:40522 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbYA2VvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 16:51:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC [M]  drivers/net/sis190.o
  drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
  make[5]: *** [drivers/net/sis190.o] Error 1

gcc --version
gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
