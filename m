From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] A few #define TRUE/FALSE removals
Date: Tue, 12 Jan 2010 22:59:12 -0800
Message-ID: <cover.1263365754.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Samuel Chessman <chessman@tux.org>,
	linux-media@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755011Ab0AMG7T@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (3):
  drivers/net/tlan: Remove TRUE/FALSE defines, use bool
  drivers/isdn/mISDN/dsp_ecdis.h: Remove #define TRUE/FALSE, use bool
  drivers/media/dvb/frontends/si21xx.c: Remove #define TRUE/FALSE, use bool

 drivers/isdn/mISDN/dsp_ecdis.h       |   20 +++++++----------
 drivers/media/dvb/frontends/si21xx.c |   38 ++++++++++++++-------------------
 drivers/net/tlan.c                   |   28 ++++++++++++------------
 drivers/net/tlan.h                   |    3 --
 4 files changed, 38 insertions(+), 51 deletions(-)
