From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 0/11] ibm_newemac: Candidate patches for 2.6.25
Date: Fri, 30 Nov 2007 16:40:23 +1100
Message-ID: <1196401223.5661.297518056501.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48276 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbXK3Fl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 00:41:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are the patches I have pending for EMAC. With those, along with
some other powerpc patches scheduled for 2.6.25 for adding support
for those various boards, I have EMAC now working properly on a
variety of platforms, such as Taishan (440GX), Katmai (440SP),
EP405 (405GP), Bamboo (440EP), etc...

This serie apply on top of the patch:

"ibm_newemac: Fix possible lockup on close"

Which should be on its way to 2.6.24 already.

