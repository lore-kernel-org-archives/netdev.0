From: Karsten Keil <karsten-keil@t-online.de>
Subject: [PATCH v2 0/3] [ISDN] Documentation patchset
Date: Thu, 23 Apr 2009 14:24:21 +0200
Message-ID: <cover.1240489461.git.keil@b1-systems.de>
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, tilman@imap.cc,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout03.t-online.de ([194.25.134.81]:42390 "EHLO
	mailout03.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbZDWMlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 08:41:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed one more typo and wrong From: lines.

Add some useful documentation for the ISDN subsystem.
Orignal patches are from Tilman Schmidt.
I fixed some whitespace issues and added the URL for the CAPI 2.0 spec.

Karsten Keil (1):
  Add reference to CAPI 2.0 standard

Tilman Schmidt (2):
  update Documentation/isdn/00-INDEX
  Documentation/isdn/INTERFACE.CAPI

 Documentation/isdn/00-INDEX       |   17 +++-
 Documentation/isdn/INTERFACE.CAPI |  213 +++++++++++++++++++++++++++++++++++++
 drivers/isdn/capi/kcapi.c         |  171 +++++++++++++++++++++++++++++
 3 files changed, 397 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/isdn/INTERFACE.CAPI

