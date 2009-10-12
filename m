From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 0/2] Build fixes for todays next tree
Date: Mon, 12 Oct 2009 16:27:17 +0100
Message-ID: <20091012152247.5694.77290.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:54484 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757163AbZJLPjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 11:39:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of networking warns/build fails
---

Alan Cox (2):
      ethoc: fix warning from 32bit build
      libertas: fix build


 drivers/net/ethoc.c                     |    3 ++-
 drivers/net/wireless/libertas/cmdresp.c |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

-- 
How do you raise an elephant ...                     with a crane

