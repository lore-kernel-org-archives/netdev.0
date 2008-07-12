From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 0/6] netxen: add support for NX3031 chip
Date: Sat, 12 Jul 2008 12:25:14 -0700
Message-ID: <1215890720-29744-1-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:33977 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752631AbYGLTZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2008 15:25:21 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is first patch series to add support for NX3031 chip and
NIC boards based on this hardware revision.

NX3031 chip has smaller PCI footprint (2MB) and different hardware              windowing. In order to retain compatibilty with older revisions,
driver has wrapper functions for register access.


