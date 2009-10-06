From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 00/11] Gigaset driver patches for 2.6.32 (v3)
Date: Wed,  7 Oct 2009 00:18:21 +0200 (CEST)
Message-ID: <20091006-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933579AbZJFWTM@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the third release of the series of patches for the Gigaset
drivers I first submitted on 2009-09-06. I have dropped the first patch
"gigaset: really fix chars_in_buffer" because it has now been merged
through the tty tree, and folded into the last one the fixes I posted on
2009-09-25 and 2009-10-01. Apart from that, the series is unchanged from
the second submission on 2009-09-19. It would be great if this could
still make it into release 2.6.32 as one more step on the way to get rid
of the deprecated ISDN4Linux subsystem.

Thanks,
Tilman
