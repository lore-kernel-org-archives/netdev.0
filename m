From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 0/8] ibm_newemac: Candidate patches for 2.6.25
Date: Wed, 21 Nov 2007 17:06:38 +1100
Message-ID: <1195625198.76200.922309668615.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38808 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454AbXKUGH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 01:07:29 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are the patches I have pending for EMAC. With some non-released
patches from Hugh Blemings, I get a taishan (440GX) booting now,
in addition to Ebony (440GP) and various 405GP boards.

This is 2.6.25 material except for patch #1 which has already been
posted separately and is candidate for 2.6.24 (and possibly stable)

