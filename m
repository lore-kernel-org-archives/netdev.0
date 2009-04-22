From: "Karsten Keil" <Karsten-Keil@t-online.de>
Subject: [PATCH 0/3] [ISDN] Documentation patchset
Date: Wed, 22 Apr 2009 16:31:48 +0200
Message-ID: <cover.1240410708.git.keil@b1-systems.de>
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, tilman@imap.cc,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754899AbZDVQhn@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some useful documentation for the ISDN subsystem.
Orignal patches are from Tilman Schmidt.
I fixed some whitespace issues and added the URL for the CAPI 2.0 spec.


Karsten Keil (1):
  Add reference to CAPI 2.0 standard

Tilman Schmidt (2):
  update Documentation/isdn/00-INDEX
  Documentation/isdn/INTERFACE.CAPI

 Documentation/isdn/00-INDEX       |   17 +++-
 Documentation/isdn/INTERFACE.CAPI |  208 +++++++++++++++++++++++++++++++++++++
 drivers/isdn/capi/kcapi.c         |  171 ++++++++++++++++++++++++++++++
 3 files changed, 392 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/isdn/INTERFACE.CAPI
