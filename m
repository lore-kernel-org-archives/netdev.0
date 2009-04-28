From: Li Yang <leoli@freescale.com>
Subject: [PATCH 0/5] rapidio: adding memory mapping IO support and misc fixes
Date: Tue, 28 Apr 2009 18:16:11 +0800
Message-ID: <2a27d3730904280316l7049bddbie914907b16ccfff6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
To: akpm@linux-foundation.org, Kumar Gala <galak@kernel.crashing.org>,
	David Miller <davem@davemloft.net>, mporter@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:58226 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759007AbZD1KQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 06:16:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series add MMIO support to Linux rapidio and fix a few nits.
 The patches cross rapidio, netdev, powerpc sub-systems.  It will be
good for them to go through one tree.  Probably Andrew?  As the
previous rapidio patches are mostly merged by you.

- Leo
