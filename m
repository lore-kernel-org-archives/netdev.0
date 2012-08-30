From: Alan Ott <alan@signal11.us>
Subject: [PATCH v6 0/1] Driver for Microchip MRF24J40
Date: Thu, 30 Aug 2012 00:16:33 -0400
Message-ID: <1346300194-3286-1-git-send-email-alan@signal11.us>
References: <1335155673-30848-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335155673-30848-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a driver for the Microchip MRF24J40 802.15.4 transceiver.

Versions 1-5 and discussion can be found on the archives of the linux-zigbee
mailing list:

http://www.mail-archive.com/linux-zigbee-devel@lists.sourceforge.net/msg01014.html

Alan Ott (1):
  ieee802154: MRF24J40 driver

 drivers/ieee802154/Kconfig    |   11 +
 drivers/ieee802154/Makefile   |    1 +
 drivers/ieee802154/mrf24j40.c |  767 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 779 insertions(+), 0 deletions(-)
 create mode 100644 drivers/ieee802154/mrf24j40.c
