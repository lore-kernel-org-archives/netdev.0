From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/9] Gigaset driver patches for 2.6.33
Date: Sun, 25 Oct 2009 20:29:27 +0100 (CET)
Message-ID: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754004AbZJYT3h@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, Karsten,

here's a series of patches that should be applied on top of those
currently in net-next. I'm sending them now to leave you enough time
before the next merge window to decide who wants to handle them.
In particular, patch 3 provides an important bugfix to the new CAPI
interface which is necessary for using it with pppd capiplugin.

Thanks,
Tilman
