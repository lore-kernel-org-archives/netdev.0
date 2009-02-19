From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 0/8] can: CAN network device driver interface and drivers
Date: Thu, 19 Feb 2009 20:01:14 +0100
Message-ID: <1235070082-7069-1-git-send-email-wg@grandegger.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757298AbZBSTCD@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the PF_CAN protocol family for the Controller Area Network is available
in the kernel since version 2.6.25 but drivers for real CAN devices are
still missing. This patch series adds a generic CAN network device
driver interface and, as a start, a few drivers. It is the result of the
ongoing discussion and development of the Socket-CAN project hosted at
the BerliOS web-server (http://developer.berlios.de/projects/socketcan).
The patch series consists of the following patches:

[PATCH 1/8] can: Documentation for the CAN device driver interface
[PATCH 2/8] can: Update MAINTAINERS and CREDITS file
[PATCH 3/8] can: CAN Network device driver and SYSFS interface
[PATCH 4/8] can: Driver for the SJA1000 CAN controller
[PATCH 5/8] can: SJA1000 generic platform bus driver
[PATCH 6/8] can: SJA1000 driver for EMS PCI cards
[PATCH 7/8] can: SJA1000 driver for Kvaser PCI cards
[PATCH 8/8] can: Driver for the Freescale MSCAN controller

Please consider these patches for inclusion.

Thanks,

Wolfgang.
